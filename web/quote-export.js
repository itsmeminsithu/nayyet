// Local image rendering: no upload, external image or third-party quote service.
export async function exportQuote({text,date,iso,lang,theme,monthlyTheme,share}) {
  await document.fonts.load('54px Pyidaungsu');
  await document.fonts.load('54px Outfit');
  await document.fonts.ready;
  const canvas=document.createElement('canvas');canvas.width=1080;canvas.height=1350;
  const c=canvas.getContext('2d');
  const g=c.createLinearGradient(0,0,0,1350);
  g.addColorStop(0,theme==='skyline'?'#242745':'#080e2e');g.addColorStop(.65,theme==='skyline'?'#b76782':'#382763');g.addColorStop(1,theme==='skyline'?'#f2b995':'#946383');
  c.fillStyle=g;c.fillRect(0,0,1080,1350);
  for(let i=0;i<95;i++){c.fillStyle=`rgba(255,255,255,${.2+(i%6)*.12})`;c.beginPath();c.arc((i*173+41)%1080,(i*277+29)%1100,1+i%3,0,Math.PI*2);c.fill();}
  c.fillStyle='#f8dfbd';c.beginPath();c.arc(830,240,75,0,Math.PI*2);c.fill();
  if(theme==='universe'){c.strokeStyle='#ffffff33';c.lineWidth=2;c.beginPath();c.ellipse(830,240,150,48,-.4,0,Math.PI*2);c.stroke();}
  else for(let layer=0;layer<2;layer++){c.fillStyle=layer?'#131b32':'#41405c';for(let i=0;i<16;i++){const h=100+(i*79+layer*43)%230;c.fillRect(i*80-layer*30,1350-h-layer*75,70,h+100);c.fillStyle='#edc59b55';for(let y=1350-h-layer*75+20;y<1300;y+=28)c.fillRect(i*80-layer*30+15,y,8,12);c.fillStyle=layer?'#131b32':'#41405c';}}
  if(theme==='monthly'&&monthlyTheme){
    const artwork=new Image();artwork.src=new URL('assets/themes/'+monthlyTheme.file,import.meta.url).href;
    await artwork.decode();
    // Fill portrait without stretching: crop the landscape illustration centrally.
    const scale=Math.max(1080/artwork.width,1350/artwork.height);
    c.drawImage(artwork,(1080-artwork.width*scale)/2,(1350-artwork.height*scale)/2,artwork.width*scale,artwork.height*scale);
    c.fillStyle='rgba(7,12,28,.36)';c.fillRect(0,0,1080,1350);
  }
  c.fillStyle='#ffffff';c.textAlign='left';c.font='32px Outfit';c.fillText('NAYYET / A MOMENT FOR YOU',90,105);
  c.font=`54px ${lang==='my'?'Pyidaungsu':'Outfit'}`;
  const segments=typeof Intl.Segmenter==='function'?[...new Intl.Segmenter(lang,{granularity:'word'}).segment(text)].map(x=>x.segment):Array.from(text);
  const lines=[];let line='';for(const word of segments){if(c.measureText(line+word).width>880&&line){lines.push(line.trim());line=word}else line+=word}if(line)lines.push(line.trim());
  const step=lang==='my'?100:85;let y=580-Math.max(0,lines.length-3)*30;
  for(const row of lines){c.fillText(row,90,y);y+=step;}
  c.font=`26px ${lang==='my'?'Pyidaungsu':'Outfit'}`;c.fillStyle='#f8e8ef';c.fillText(date,90,1070);
  c.font='25px Pyidaungsu, Outfit';c.fillText('နေ့ရက် — NayYet  ·  minsithu.org',90,1150);
  const blob=await new Promise((resolve,reject)=>canvas.toBlob(b=>b?resolve(b):reject(new Error('PNG export failed')),'image/png'));
  const file=new File([blob],`nayyet-${iso}-${theme}.png`,{type:'image/png'});
  if(share&&navigator.canShare?.({files:[file]})){try{await navigator.share({files:[file],title:'NayYet'});return 'shared'}catch(e){if(e.name==='AbortError')return 'cancelled';throw e}}
  const url=URL.createObjectURL(blob),a=document.createElement('a');a.href=url;a.download=file.name;document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),60000);return 'downloaded';
}
