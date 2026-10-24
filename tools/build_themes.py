"""Render original vector theme artwork. Optional dependency: cairosvg."""
from pathlib import Path
import json, math, shutil
import cairosvg
ROOT=Path(__file__).resolve().parents[1]
themes=json.loads((ROOT/'shared/themes.json').read_text())
for theme in themes:
    month=theme['month'];scene=theme['scene']
    parts=[f'<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="900" viewBox="0 0 1600 900"><defs><linearGradient id="sky" x2="0" y2="1"><stop stop-color="{theme["top"]}"/><stop offset="1" stop-color="{theme["bottom"]}"/></linearGradient><radialGradient id="glow"><stop stop-color="#fce7b5" stop-opacity=".45"/><stop offset="1" stop-color="#fce7b5" stop-opacity="0"/></radialGradient></defs><path fill="url(#sky)" d="M0 0h1600v900H0z"/>']
    for i in range(100 if scene not in ['village','beach','taunggyi','inle','bagan'] else 0):
        x=(i*193+month*79)%1600;y=(i*127+month*31)%650
        parts.append(f'<circle cx="{x}" cy="{y}" r="{1+i%3}" fill="white" opacity="{.12+(i%5)*.09}"/>')
    cx=1190-month*9;cy=225
    parts.append(f'<circle cx="{cx}" cy="{cy}" r="210" fill="url(#glow)"/><circle cx="{cx}" cy="{cy}" r="68" fill="#f8deb2"/>')
    if scene=='cosmic':
        parts.append(f'<ellipse cx="{cx}" cy="{cy}" rx="170" ry="38" fill="none" stroke="#dfb8e7" stroke-width="4" transform="rotate(-25 {cx} {cy})"/>')
        for i in range(6):parts.append(f'<path d="M{-100+i*30} {850-i*35} Q700 {-300+i*90} 1700 {300+i*50}" fill="none" stroke="#d8b7f1" stroke-opacity=".06" stroke-width="35"/>')
    for layer in range(3):
        pts=[f'{x},{int(650+layer*80-110*math.sin(x/190+month+layer)-65*math.cos(x/113+layer))}' for x in range(-100,1801,100)]
        parts.append(f'<polygon points="-100,900 {" ".join(pts)} 1800,900" fill="{theme["top"]}" opacity="{.25+layer*.23}"/>')
    if scene in ['river','rain']:
        parts.append('<path d="M850 590 Q650 720 1050 770 Q1300 830 650 900H1400 Q1630 790 1120 720 Q860 660 900 590" fill="#afd3d9" opacity=".3"/>')
    if scene=='rain':
        for i in range(85):
            x=i*41%1600;y=i*91%800
            parts.append(f'<path d="M{x} {y}l-18 45" stroke="#d2e4f0" opacity=".16" stroke-width="2"/>')
    if scene=='pagoda':
        for x,y,k in [(1130,810,1.1),(410,860,.7),(1450,870,.55)]:
            parts.append(f'<g transform="translate({x} {y}) scale({k})" fill="#e5b56c"><path d="M-140 0H140V-22H116V-43H92V-62H75Q70-155 40-180L20-215 8-260 0-310 -8-260 -20-215 -40-180Q-70-155 -75-62H-92V-43H-116V-22H-140Z"/><path d="M-65-82H65M-47-160H47" stroke="#94734b" fill="none" stroke-width="4"/></g>')
        if month==10:
            for i in range(12):parts.append(f'<rect x="{100+i*123}" y="{90+(i*83)%350}" width="13" height="20" rx="3" fill="#ffd88c" opacity=".7"/>')
    if scene=='skyline':
        for i in range(30):
            h=70+(i*73)%230;x=i*58
            parts.append(f'<rect x="{x}" y="{900-h}" width="49" height="{h}" fill="#182236"/>')
            for y in range(920-h,870,27):parts.append(f'<rect x="{x+12}" y="{y}" width="7" height="10" fill="#ffd994" opacity=".5"/>')
    # Myanmar scenery: central landmarks stay visible in portrait quote crops.
    if scene=='bagan':
        parts.append('<path d="M0 690Q800 610 1600 690V900H0Z" fill="#a87457"/>')
        for x,y,k in [(260,800,.65),(540,760,.8),(810,850,1.3),(1090,780,.7),(1390,820,.9)]:
            parts.append(f'<g transform="translate({x} {y}) scale({k})"><path d="M-85 0V-65H-65V-105L-42-140 -25-170 -12-205 0-265 12-205 25-170 42-140 65-105V-65H85V0Z" fill="#784938"/><path d="M-105 0H105M-82-28H82M-65-65H65" stroke="#d1a076" stroke-width="7"/><path d="M-18 0V-45Q0-77 18-45V0" fill="#3b3036"/></g>')
    if scene=='village':
        parts.append('<path d="M0 630Q800 590 1600 650V900H0Z" fill="#749052"/>')
        for y in [690,770,850]:parts.append(f'<path d="M0 {y}Q800 {y-80} 1600 {y}" fill="none" stroke="#c2b36d" stroke-width="9"/>')
        parts.append('<path d="M940 640Q700 760 890 900H1050Q820 770 980 640" fill="#c6a477"/>')
        for x,y,k in [(540,760,.8),(820,695,.65),(1120,780,1)]:
            parts.append(f'<g transform="translate({x} {y}) scale({k})"><path d="M-65 0V-95H65V0" fill="#b38b58"/><path d="M-90-95L0-165 90-95Z" fill="#594536"/><path d="M-52 0V35M52 0V35" stroke="#493d31" stroke-width="10"/><path d="M-13 0V-60H15V0" fill="#534b39"/></g>')
        for x in [300,1230]:parts.append(f'<path d="M{x} 740V500" stroke="#5c5038" stroke-width="18"/><ellipse cx="{x}" cy="490" rx="105" ry="80" fill="#3e6347"/>')
    if scene=='beach':
        parts.append('<path d="M0 510H1600V900H0Z" fill="#479caa"/><path d="M0 830Q650 590 1600 780V900H0Z" fill="#ead3a1"/><path d="M0 805Q650 565 1600 755" fill="none" stroke="#e6f6ed" stroke-width="15"/>')
        for y in [560,610,660]:parts.append(f'<path d="M0 {y}Q400 {y-20} 800 {y}T1600 {y}" stroke="#b8e3df" stroke-width="3" fill="none" opacity=".55"/>')
        for x,y,k in [(470,870,1),(1040,880,.8)]:
            parts.append(f'<g transform="translate({x} {y}) scale({k})"><path d="M0 0Q-35-150 20-320" stroke="#6f6148" stroke-width="22" fill="none"/>')
            for dx,dy in [(-150,-20),(-120,-100),(10,-120),(140,-70),(160,20)]:parts.append(f'<path d="M20-320Q{dx//2}-410 {dx} {-320+dy}Q{dx//2}-325 20-320" fill="#285f53"/>')
            parts.append('</g>')
    if scene=='taunggyi':
        for y in [500,580,650]:parts.append(f'<path d="M0 {y}Q500 {y-90} 1600 {y+30}" fill="none" stroke="#d8e5dc" stroke-width="32" opacity=".18"/>')
        for x,y,k in [(460,850,1.2),(1060,850,1),(1250,900,1.5),(700,840,.6)]:
            parts.append(f'<g transform="translate({x} {y}) scale({k})"><path d="M0 0V-250" stroke="#344a43" stroke-width="12"/><path d="M0-320L-70-190H-40L-95-100H95L40-190H70Z" fill="#284b45"/></g>')
        for x in range(660,1000,55):parts.append(f'<rect x="{x}" y="730" width="40" height="36" fill="#c3bc9c"/><path d="M{x-5} 730L{x+20} 708 {x+45} 730Z" fill="#796d62"/>')
    if scene=='inle':
        parts.append('<path d="M0 600Q800 570 1600 600V900H0Z" fill="#64999f"/>')
        for y in range(630,900,38):parts.append(f'<path d="M0 {y}Q400 {y-12} 800 {y}T1600 {y}" stroke="#b7d7d2" opacity=".3" fill="none" stroke-width="3"/>')
        for x in [400,1100]:parts.append(f'<path d="M{x} 720V620H{x+135}V720M{x+20} 720V800M{x+110} 720V800" fill="#796653" stroke="#514f47" stroke-width="9"/><path d="M{x-20} 620L{x+68} 565 {x+155} 620Z" fill="#514e4b"/>')
        parts.append('<path d="M650 820Q800 865 950 820L915 846H690Z" fill="#343d3e"/><circle cx="800" cy="688" r="15" fill="#3c4443"/><path d="M800 702L788 763 765 815M788 763L827 805M795 725L850 750M850 700L900 860" fill="none" stroke="#3c4443" stroke-width="12" stroke-linecap="round"/>')
    parts.append('</svg>');svg=''.join(parts)
    folder=ROOT/'shared/themes';folder.mkdir(exist_ok=True)
    (folder/f'theme-{month:02d}.svg').write_text(svg)
    cairosvg.svg2png(bytestring=svg.encode(),write_to=str(folder/theme['file']))
    for relative in ['web/assets/themes','android_flutter/assets/themes','ios_swift/NayYet/Resources/themes']:
        dest=ROOT/relative;dest.mkdir(parents=True,exist_ok=True);shutil.copy2(folder/theme['file'],dest/theme['file'])
    catalog=ROOT/f'ios_swift/NayYet/Assets.xcassets/theme-{month:02d}.imageset'
    catalog.mkdir(parents=True,exist_ok=True)
    shutil.copy2(folder/theme['file'],catalog/theme['file'])
    (catalog/'Contents.json').write_text(json.dumps({'images':[{'filename':theme['file'],'idiom':'universal'}],'info':{'author':'xcode','version':1}}))
print('Rendered and copied 12 monthly themes.')
