#!/usr/bin/env python3
"""Draw assets/logo.svg: a pixel brew mug and ANSI-Shadow block letters, in ruby.
Everything is rects, so it looks the same without the font. usage: python3 assets/logo.py assets/logo.svg"""
import sys

L = {
'M': ["███╗   ███╗","████╗ ████║","██╔████╔██║","██║╚██╔╝██║","██║ ╚═╝ ██║","╚═╝     ╚═╝"],
'O': [" ██████╗ ","██╔═══██╗","██║   ██║","██║   ██║","╚██████╔╝"," ╚═════╝ "],
'C': [" ██████╗","██╔════╝","██║     ","██║     ","╚██████╗"," ╚═════╝"],
'K': ["██╗  ██╗","██║ ██╔╝","█████╔╝ ","██╔═██╗ ","██║  ██╗","╚═╝  ╚═╝"],
'I': ["██╗","██║","██║","██║","██║","╚═╝"],
'N': ["███╗   ██╗","████╗  ██║","██╔██╗ ██║","██║╚██╗██║","██║ ╚████║","╚═╝  ╚═══╝"],
'G': [" ██████╗ ","██╔════╝ ","██║  ███╗","██║   ██║","╚██████╔╝"," ╚═════╝ "],
'B': ["██████╗ ","██╔══██╗","██████╔╝","██╔══██╗","██████╔╝","╚═════╝ "],
'R': ["██████╗ ","██╔══██╗","██████╔╝","██╔══██╗","██║  ██║","╚═╝  ╚═╝"],
'D': ["██████╗ ","██╔══██╗","██║  ██║","██║  ██║","██████╔╝","╚═════╝ "],
}
rows = ["".join(L[c][r] for c in "MOCKINGBIRD") for r in range(6)]

# An original pixel mug: f foam, F foam shade, b brew, s glass shine, o bubble, g glass, h handle.
MUG = [
    "...fff.ffff.....",
    "..fffffffffff...",
    ".fffffffffffff..",
    ".fffffffffffff..",
    ".gFfbFFfFFbFg...",
    ".gbbbbbbbbbbghhh",
    ".gsbbbbobbbbg..h",
    ".gsbbbbbbbobg..h",
    ".gsbobbbbbbbg..h",
    ".gsbbbbbbbbbg..h",
    ".gsbbbbbobbbghhh",
    ".gbbbbbbbbbbg...",
    ".gbbbbobbbbbg...",
    ".gbbbbbbbbbbg...",
    "..gggggggggg....",
]
MC = {'f': '#ffe8ef', 'F': '#ffb3c8', 'b': 'url(#brew)', 's': '#ff8fab', 'o': '#ffc2d4', 'g': '#ff4d79', 'h': '#ff4d79'}

P = 11                      # mug pixel
MX, MY = 56, 100            # mug origin
CW, CH, T = 9, 18, 3        # letter cell width, height, stroke
OX, OY = MX + 16 * P + 40, 112
W = OX + len(rows[0]) * CW + 50
H = 340

mug = "".join(f'<rect x="{MX + x*P}" y="{MY + y*P}" width="{P}" height="{P}" fill="{MC[c]}"/>'
              for y, r in enumerate(MUG) for x, c in enumerate(r) if c in MC)

fill, shade = [], []
for y, row in enumerate(rows):
    for x, ch in enumerate(row):
        px, py = OX + x * CW, OY + y * CH
        cx, cy = px + CW // 2 - T // 2, py + CH // 2 - T // 2
        if ch == '█':
            fill.append(f'<rect x="{px}" y="{py}" width="{CW}" height="{CH}"/>'); continue
        hl = f'<rect x="{px}" y="{cy}" width="{CW//2+T//2+1}" height="{T}"/>'
        hr = f'<rect x="{cx}" y="{cy}" width="{CW-CW//2+T//2}" height="{T}"/>'
        vt = f'<rect x="{cx}" y="{py}" width="{T}" height="{CH//2+T//2+1}"/>'
        vb = f'<rect x="{cx}" y="{cy}" width="{T}" height="{CH-CH//2+T//2}"/>'
        shade += {'═': [f'<rect x="{px}" y="{cy}" width="{CW}" height="{T}"/>'],
                  '║': [f'<rect x="{cx}" y="{py}" width="{T}" height="{CH}"/>'],
                  '╗': [hl, vb], '╔': [hr, vb], '╝': [hl, vt], '╚': [hr, vt]}.get(ch, [])

mono = "ui-monospace, 'SF Mono', Menlo, Consolas, 'DejaVu Sans Mono', monospace"
ty = OY + 6 * CH
svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="img" aria-label="homebrew-mockingbird">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#ff6b8b"/><stop offset="0.5" stop-color="#e0115f"/><stop offset="1" stop-color="#9b111e"/>
    </linearGradient>
    <linearGradient id="brew" gradientUnits="userSpaceOnUse" x1="0" x2="0" y1="{MY + 4*P}" y2="{MY + 14*P}">
      <stop offset="0" stop-color="#e0115f"/><stop offset="1" stop-color="#7a0c1c"/>
    </linearGradient>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#16050b"/><stop offset="1" stop-color="#080205"/>
    </linearGradient>
    <filter id="glow" x="-10%" y="-30%" width="120%" height="160%">
      <feGaussianBlur stdDeviation="4" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <pattern id="scan" width="4" height="4" patternUnits="userSpaceOnUse"><rect width="4" height="1" fill="#000" opacity="0.35"/></pattern>
    <pattern id="grid" width="22" height="22" patternUnits="userSpaceOnUse"><path d="M22 0H0V22" fill="none" stroke="#3a0d1a" stroke-width="1" opacity="0.6"/></pattern>
  </defs>
  <rect x="1" y="1" width="{W-2}" height="{H-2}" rx="14" fill="url(#bg)" stroke="#7a1830" stroke-width="2"/>
  <rect x="1" y="1" width="{W-2}" height="{H-2}" rx="14" fill="url(#grid)"/>
  <rect x="1" y="1" width="{W-2}" height="38" rx="14" fill="#220810"/><rect x="1" y="26" width="{W-2}" height="13" fill="#220810"/>
  <line x1="1" y1="39" x2="{W-1}" y2="39" stroke="#7a1830" stroke-width="1.5"/>
  <circle cx="26" cy="20" r="6" fill="#ff4d79"/><circle cx="46" cy="20" r="6" fill="#c2185b"/><circle cx="66" cy="20" r="6" fill="#6b1328"/>
  <text x="{W/2}" y="25" text-anchor="middle" font-family="{mono}" font-size="14" fill="#c26a80">homebrew-mockingbird — brew tap</text>
  <text x="{MX}" y="76" font-family="{mono}" font-size="17" fill="#ffd0dc"><tspan fill="#ff4d79">❯</tspan> brew install nirjharbhattacharjee/mockingbird/mockingbird</text>
  <g filter="url(#glow)">{mug}</g>
  <g fill="#6b0f22">{''.join(shade)}</g>
  <g fill="url(#g)" filter="url(#glow)">{''.join(fill)}</g>
  <text x="{OX}" y="{ty + 40}" font-family="{mono}" font-size="18" fill="#ff9db3">the homebrew tap<tspan fill="#ff4d79">
    <animate attributeName="opacity" values="1;1;0;0" keyTimes="0;0.5;0.5;1" dur="1.1s" repeatCount="indefinite"/>█</tspan></text>
  <text x="{OX}" y="{ty + 68}" font-family="{mono}" font-size="14" fill="#a8495f">a local video editing engine for AI agents</text>
  <rect x="1" y="1" width="{W-2}" height="{H-2}" rx="14" fill="url(#scan)"/>
</svg>
'''
open(sys.argv[1], 'w').write(svg)
print(W, H)
