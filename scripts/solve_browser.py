#!/usr/bin/env python3
"""Robust browser path for an Invidious instance whose media is cap.js-gated.

Solves the widget by clicking the real shadow-DOM checkbox (trusted click), saves
captcha_verified cookies + the check= token the watch page embeds, and prints the
fresh cookies.  Use those in the plain-curl DASH download (03_video.sh rung 2).

Usage:  xvfb-run -a -s "-screen 0 1280x900x24" python3 solve_browser.py VIDEO_ID INSTANCE
Deps:   pip install playwright; playwright install chromium; apt install xvfb
"""
import asyncio, json, sys, subprocess
from playwright.async_api import async_playwright

VID = sys.argv[1]
INST = sys.argv[2] if len(sys.argv) > 2 else "yt.chocolatemoo53.com"
BASE = f"https://{INST}"

async def main():
    async with async_playwright() as p:
        br = await p.chromium.launch(headless=False, ignore_default_args=["--enable-automation"],
              args=["--no-sandbox","--disable-blink-features=AutomationControlled"])
        ctx = await br.new_context(user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                                   "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36")
        page = await ctx.new_page()
        await page.add_init_script("Object.defineProperty(navigator,'webdriver',{get:()=>undefined});")
        await page.goto(f"{BASE}/watch?v={VID}", wait_until="domcontentloaded", timeout=90000)
        await asyncio.sleep(6)
        # fall back: many gates want one interactive click, others solve themselves
        try:
            box = await page.evaluate("""(()=>{const w=document.querySelector('cap-widget');
                if(!w||!w.shadowRoot)return null;
                const t=w.shadowRoot.querySelector('button, .captcha');if(!t)return null;
                const rb=t.getBoundingClientRect();return{x:rb.x+rb.width/2,y:rb.y+rb.height/2};})()""")
        except Exception:
            box = None
        if box:
            await page.mouse.click(box["x"], box["y"])
        for i in range(40):
            await asyncio.sleep(2)
            try:
                gone = (await page.evaluate("!!document.querySelector('cap-widget')")) is False
            except Exception:
                gone = False
            ck = await ctx.cookies()
            if gone or any(c["name"] == "captcha_verified" for c in ck):
                print("solved/cleared")
                break
        cookies = await ctx.cookies()
        html = await page.evaluate("document.documentElement.innerHTML")
        import re
        m = re.search(r"check=([A-Za-z0-9_\-=]+)", html)
        with open("cookies.json", "w") as f:
            json.dump(cookies, f)
        with open("check.txt", "w") as f:
            f.write(m.group(1) if m else "")
        with open("cookiejar.txt", "w") as f:
            f.write("# Netscape HTTP Cookie File\n")
            for c in cookies:
                dom = c["domain"]
                if not dom.startswith("."):
                    dom = "." + dom.lstrip(".")
                f.write("\t".join([dom, "TRUE", c.get("path", "/"), "FALSE", "0",
                                   c["name"], c["value"]]) + "\n")
        print(f"cookies.json, check.txt, cookiejar.txt written (check: {m.group(1)[:20] if m else 'none'}…)")
        await br.close()

asyncio.run(main())
