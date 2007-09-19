// Created by iWeb 2.0.1 local-build-20070919

setTransparentGifURL('Media/transparent.gif');function applyEffects()
{var registry=IWCreateEffectRegistry();registry.registerEffects({stroke_0:new IWStrokeParts([{rect:new IWRect(-1,1,2,98),url:'Donations_files/stroke.png'},{rect:new IWRect(-1,-1,2,2),url:'Donations_files/stroke_1.png'},{rect:new IWRect(1,-1,270,2),url:'Donations_files/stroke_2.png'},{rect:new IWRect(271,-1,2,2),url:'Donations_files/stroke_3.png'},{rect:new IWRect(271,1,2,98),url:'Donations_files/stroke_4.png'},{rect:new IWRect(271,99,2,2),url:'Donations_files/stroke_5.png'},{rect:new IWRect(1,99,270,2),url:'Donations_files/stroke_6.png'},{rect:new IWRect(-1,99,2,2),url:'Donations_files/stroke_7.png'}],new IWSize(272,100))});registry.applyEffects();}
function hostedOnDM()
{return false;}
function onPageLoad()
{loadMozillaCSS('Donations_files/DonationsMoz.css')
adjustLineHeightIfTooBig('id1');adjustFontSizeIfTooBig('id1');adjustLineHeightIfTooBig('id2');adjustFontSizeIfTooBig('id2');adjustLineHeightIfTooBig('id3');adjustFontSizeIfTooBig('id3');detectBrowser();adjustLineHeightIfTooBig('id4');adjustFontSizeIfTooBig('id4');adjustLineHeightIfTooBig('id5');adjustFontSizeIfTooBig('id5');adjustLineHeightIfTooBig('id6');adjustFontSizeIfTooBig('id6');adjustLineHeightIfTooBig('id7');adjustFontSizeIfTooBig('id7');Widget.onload();fixAllIEPNGs('Media/transparent.gif');applyEffects()}
function onPageUnload()
{Widget.onunload();}
