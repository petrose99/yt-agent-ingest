#!/usr/bin/env python3
"""Solver for cap.js classic (sha256-pow) CAPTCHA — FNV-1a/xorshift challenge family.

Reference: /challeng endpoint at {CAP_API}/challenge → {challenge:{c,s,d}, token, ...}
Flow: solve c challenges → POST {CAP_API}/redeem { token, solutions } → success: token.

Usage:
  python3 cap_solver.py https://cap.example.com/SITEKEY/     # solve + redeem, print token
"""
import base64, hashlib, http.cookiejar, json, sys, urllib.request

def fnv31(seed):
    r = 2166136261
    for a in seed:
        r ^= ord(a)
        r = (r + ((r << 1) + (r << 4) + (r << 7) + (r << 8) + (r << 24))) & 0xFFFFFFFF
    return r

def V(seed, ln):
    """Deterministic hex-string generator (cap.js client-side seed derivation)."""
    t = fnv31(seed)
    total = ''
    while len(total) < ln:
        t ^= (t << 13) & 0xFFFFFFFF; t &= 0xFFFFFFFF
        t ^= t >> 17
        t ^= (t << 5) & 0xFFFFFFFF; t &= 0xFFFFFFFF
        total += format(t, '08x')
    return total[:ln]

def solve_one(salt, target_hex):
    """Find nonce n such that sha256(salt+str(n)) hex starts with target_hex."""
    i = target_hex if len(target_hex) % 2 == 0 else target_hex + '0'
    ccount = len(i) // 2
    fb = bytes(int(i[2*j:2*j+2], 16) for j in range(ccount))
    a = 4*len(target_hex)//8
    l = 4*len(target_hex) % 8
    w = (255 << 8-l) & 255 if l > 0 else 0
    sha = hashlib.sha256
    nonce = 0
    while True:
        h = sha((salt + str(nonce)).encode()).digest()
        if h[:a] == fb[:a] and (l == 0 or (h[a] & w) == (fb[a] & w)):
            return nonce
        nonce += 1

def solve(ep):
    jar = http.cookiejar.CookieJar()
    op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))
    op.addheaders = [('User-Agent','Mozilla/5.0'), ('Origin', 'https://cap.placeholder.invalid')]
    req = urllib.request.Request(ep.rstrip('/') + '/challenge', method='POST', data=b'{}',
                                 headers={'Content-Type':'application/json'})
    d = json.load(op.open(req, timeout=30))
    if 'challenge' not in d or 'token' not in d:
        print('format-2 challenge (hashwx / instrumentation) not supported here — use the browser path',
              file=sys.stderr); return None
    ch, tok = d['challenge'], d['token']
    c, s, dl = int(ch['c']), int(ch['s']), int(ch['d'])
    print(f'{c} challenges, salt len {s}, target {dl} hex digits')
    sols = [solve_one(V(f"{tok}{i}", s), V(f"{tok}{i}d", dl)) for i in range(1, c+1)]
    req = urllib.request.Request(ep.rstrip('/') + '/redeem', method='POST',
        data=json.dumps({'token': tok, 'solutions': sols}).encode(),
        headers={'Content-Type':'application/json'})
    r = json.load(op.open(req, timeout=30))
    if r.get('success'):
        return r['token'], [ (c.name, c.value) for c in jar ]
    print(json.dumps(r)[:400], file=sys.stderr)
    return None

if __name__ == '__main__':
    ep = sys.argv[1]
    got = solve(ep)
    if got:
        token, cookies = got
        print('cap token:', token)
        for n, v in cookies:
            print(f'{n}={v}')
