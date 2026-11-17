// OverPy 9.7.21's createCasedProgressBarIwt line splitter (generateCasedLine), copied so a
// macro can build the lowercased layers as strings. Widths cut to printable ASCII and the
// soft hyphen, as it's only used on dates and video links.
var spaces = {"1":" ","2":" ","71":" ","128":" ","142":" ","171":" ","223":"฀","256":" ","461":"ㅤ","512":" "};
var blizzGlobalDefaultWidth = 512;
var blizzGlobalWidths = {"0":285,"1":285,"2":285,"3":285,"4":285,"5":285,"6":285,"7":285,"8":285,"9":285," ":142,"!":142,"\"":182,"#":285,"$":285,"%":455,"&":342,"'":98,"(":170,")":170,"*":199,"+":299,",":142,"-":170,".":142,"/":142,":":142,";":142,"<":299,"=":299,">":299,"?":285,"@":520,"A":342,"B":342,"C":370,"D":370,"E":342,"F":313,"G":398,"H":370,"I":142,"J":256,"K":342,"L":285,"M":426,"N":370,"O":398,"P":342,"Q":398,"R":370,"S":342,"T":313,"U":370,"V":342,"W":483,"X":342,"Y":342,"Z":313,"[":142,"\\":142,"]":142,"^":240,"_":256,"`":256,"a":285,"b":285,"c":256,"d":285,"e":285,"f":142,"g":285,"h":285,"i":114,"j":114,"k":256,"l":114,"m":426,"n":285,"o":285,"p":285,"q":285,"r":170,"s":256,"t":142,"u":285,"v":256,"w":370,"x":256,"y":256,"z":256,"{":171,"|":133,"}":171,"~":256,"­":0};
var alphabet2 = {"a":{"lower":"ａ","width":285,"xmin":21,"lowerWidth":512,"lowerXmin":130},"b":{"lower":"ｂ","width":285,"xmin":28,"lowerWidth":512,"lowerXmin":136},"c":{"lower":"ｃ","width":256,"xmin":16,"lowerWidth":512,"lowerXmin":142},"d":{"lower":"ｄ","width":285,"xmin":13,"lowerWidth":512,"lowerXmin":136},"e":{"lower":"ｅ","width":285,"xmin":20,"lowerWidth":512,"lowerXmin":135},"f":{"lower":"ｆ","width":142,"xmin":9,"lowerWidth":512,"lowerXmin":195},"g":{"lower":"ｇ","width":285,"xmin":15,"lowerWidth":512,"lowerXmin":138},"h":{"lower":"ｈ","width":285,"xmin":36,"lowerWidth":512,"lowerXmin":150},"i":{"lower":"і","width":114,"xmin":34,"lowerWidth":115,"lowerXmin":36},"j":{"lower":"ј","width":114,"xmin":-9,"lowerWidth":115,"lowerXmin":-9},"k":{"lower":"ｋ","width":256,"xmin":30,"lowerWidth":512,"lowerXmin":142},"l":{"lower":"I","width":114,"xmin":35,"lowerWidth":142,"lowerXmin":51},"m":{"lower":"ｍ","width":426,"xmin":36,"lowerWidth":512,"lowerXmin":79},"n":{"lower":"ｎ","width":285,"xmin":36,"lowerWidth":512,"lowerXmin":149},"o":{"lower":"ｏ","width":285,"xmin":18,"lowerWidth":512,"lowerXmin":135},"p":{"lower":"ｐ","width":285,"xmin":28,"lowerWidth":512,"lowerXmin":136},"q":{"lower":"ｑ","width":285,"xmin":13,"lowerWidth":512,"lowerXmin":136},"r":{"lower":"ｒ","width":170,"xmin":35,"lowerWidth":512,"lowerXmin":191},"s":{"lower":"ｓ","width":256,"xmin":17,"lowerWidth":512,"lowerXmin":147},"t":{"lower":"ｔ","width":142,"xmin":7,"lowerWidth":512,"lowerXmin":195},"u":{"lower":"ｕ","width":285,"xmin":33,"lowerWidth":512,"lowerXmin":149},"v":{"lower":"ｖ","width":256,"xmin":5,"lowerWidth":512,"lowerXmin":134},"w":{"lower":"ｗ","width":370,"xmin":3,"lowerWidth":512,"lowerXmin":76},"x":{"lower":"ｘ","width":256,"xmin":9,"lowerWidth":512,"lowerXmin":139},"y":{"lower":"ｙ","width":256,"xmin":10,"lowerWidth":512,"lowerXmin":139},"z":{"lower":"ｚ","width":256,"xmin":16,"lowerWidth":512,"lowerXmin":147}};
function getBestSpaces(coins, target) {
  let costs = [0];
  let coins_used = [0];
  for (let i = 1; i <= target; i++) {
    let bestCost = 999999999999999;
    let bestCoin = -1;
    for (let coin of coins) {
      if (coin <= i) {
        let cost = 1 + costs[i - coin];
        if (cost < bestCost) {
          bestCost = cost;
          bestCoin = coin;
        }
      }
    }
    costs.push(bestCost);
    coins_used.push(bestCoin);
  }
  let ret = [];
  while (target > 0) {
    ret.push(coins_used[target]);
    target -= coins_used[target];
  }
  return ret;
}
function generateCasedLine(text, nbTexts) {
  let textWidth = 0;
  let foundLetterToLowercase = false;
  let textCopy = text.replace(/(<fg\s*#?[0-9a-f\{\}]+>|<\/fg>)/gi, "");
  for (let i = 0; i < textCopy.length; i++) {
    if (textCopy.charAt(i) in alphabet2) {
      foundLetterToLowercase = true;
    }
    if ("abcdefghkmnopqrstuvwxyz".includes(textCopy.charAt(i))) {
      textWidth = Math.max(0, alphabet2[textCopy.charAt(i)].lowerXmin - textWidth);
      break;
    } else {
      textWidth += blizzGlobalWidths[textCopy.charAt(i)] ?? blizzGlobalDefaultWidth;
    }
  }
  if (!foundLetterToLowercase) {
    return Array(nbTexts).fill(0).map(() => text);
  }
  const texts = Array(nbTexts).fill(0).map(() => ({
    content: "",
    width: 0
  }));
  let textIdx = 0;
  let lastLetter = "";
  for (let i = 0; i < text.length; i++) {
    const letter = text[i];
    if (letter in alphabet2) {
      textIdx += 1;
      textIdx %= nbTexts;
      const widthToGet = Math.max(0, textWidth - texts[textIdx].width - alphabet2[letter].lowerXmin + alphabet2[letter].xmin);
      const spacesToAdd = getBestSpaces(Object.keys(spaces).map(Number), widthToGet).map((j) => spaces[j]).join("");
      texts[textIdx].content += spacesToAdd;
      texts[textIdx].width += widthToGet;
      texts[textIdx].content += alphabet2[letter].lower;
      texts[textIdx].width += alphabet2[letter].lowerWidth;
      lastLetter = letter;
    } else if (text.substring(i).match(/^(<fg\s*#?[0-9a-f\{\}]+>|<\/fg>)/i)) {
      for (let _text of texts) {
        _text.content += text.substring(i, text.indexOf(">", i) + 1);
      }
      i = text.indexOf(">", i);
      textIdx += 1;
      textIdx %= nbTexts;
      continue;
    } else if (letter !== " ") {
      if (texts[textIdx].content.length === 0 || lastLetter in alphabet2 || lastLetter === " ") {
        textIdx += 1;
        textIdx %= nbTexts;
        const widthToGet = textWidth - texts[textIdx].width;
        const spacesToAdd = getBestSpaces(Object.keys(spaces).map(Number), widthToGet).map((j) => spaces[j]).join("");
        texts[textIdx].content += spacesToAdd;
        texts[textIdx].width += widthToGet;
      }
      texts[textIdx].content += letter;
      texts[textIdx].width += blizzGlobalWidths[letter] ?? blizzGlobalDefaultWidth;
      lastLetter = letter;
    } else if (letter === " ") {
      lastLetter = letter;
    }
    textWidth += blizzGlobalWidths[letter] ?? blizzGlobalDefaultWidth;
  }
  const maxTextWidth = Math.max(...texts.map((t) => t.width), textWidth);
  for (let i = 0; i < texts.length; i++) {
    const widthToGet = maxTextWidth - texts[i].width;
    const spacesToAdd = getBestSpaces(Object.keys(spaces).map(Number), widthToGet).map((j) => spaces[j]).join("");
    texts[i].content += spacesToAdd;
    texts[i].width += widthToGet;
  }
  return texts.map((t) => t.content);
}

// lbRunInfo(rank, date, link): a run's date and link as the 3 lowercased layers OverPy's
// createCasedProgressBarIwt(3, …) would draw for "\n<fgFFFFFFFF>date</fg>\n<fgFFFFFFFF>link</fg>",
// each without the blank lines around it (lbRunPad), which Show Run Info adds.
// assistedLbRunInfo(assistedRank, date, link) runs this too: its rows are 11 to 20.
var row = typeof assistedRank !== "undefined" ? assistedRank + 10 : rank;
var dateLayers = generateCasedLine("  <fgFFFFFFFF>" + date + "</fg>  ", 3);
var linkLayers = generateCasedLine("  <fgFFFFFFFF>" + link + "</fg>", 3);
"lbRunInfoText[" + row + "] = [" +
    [0, 1, 2].map((k) => JSON.stringify("  \xAD\n" + dateLayers[k] + "\xAD\n" + linkLayers[k])).join(", ") +
    "]";
