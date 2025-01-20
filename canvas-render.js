const fs = require("fs");
const { createCanvas, loadImage } = require("canvas");
const { JSDOM } = require("jsdom");
const path = require("path");

async function renderHtmlToCanvas() {
  const templateHtml = fs.readFileSync("/templates/telekom.html", "utf-8");

  const dom = new JSDOM(templateHtml);
  const document = dom.window.document;

  const canvas = createCanvas(480, 800);
  const ctx = canvas.getContext("2d");

  ctx.imageSmoothingEnabled = false;

  ctx.fillStyle = "white";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  ctx.font = '17px "Arial Narrow"';
  ctx.textBaseline = "top";

  function drawText(text, x, y, font) {
    ctx.font = font || '17px "Arial Narrow"';
    ctx.fillStyle = "black";
    ctx.fillText(text, Math.round(x), Math.round(y));
  }

  const margin = 22;

  try {
    const img = await loadImage("https://example.com/phone-image.jpg");
    const imgHeight = 300;
    const imgWidth = (img.width * imgHeight) / img.height;
    const x = (480 - imgWidth) / 2;
    ctx.drawImage(img, x, 0, imgWidth, imgHeight);
  } catch (error) {
    console.log("Could not load header image, skipping...");
  }

  ctx.font = "32px Arial";
  ctx.textAlign = "center";
  const nameBox = document.querySelector(".name-box");
  drawText("Samsung", 240, 320, "32px Arial");
  drawText("Galaxy S24 Ultra", 240, 355, "bold 32px Arial");
  drawText("512GB", 240, 390, "32px Arial");

  ctx.textAlign = "left";
  drawText("660,00 €", margin, 450, "bold 30px Arial");
  drawText("ali", 220, 450, '17px "Arial Narrow"');
  drawText("24 x", 280, 450, "28px Arial");
  drawText("27,50 €", 340, 450, "bold 30px Arial");

  drawText(
    "akcijska cena vezava 24 mesecev",
    margin,
    490,
    '17px "Arial Narrow"'
  );

  drawText("952,80 €", margin, 530, "bold 30px Arial");
  drawText("ali", 220, 530, '17px "Arial Narrow"');
  drawText("24 x", 280, 530, "28px Arial");
  drawText("39,70 €", 340, 530, "bold 30px Arial");

  drawText(
    "Program zvestobe vezava 24 mesecev + 300 točk",
    margin,
    570,
    '17px "Arial Narrow"'
  );

  drawText("660,00 €", margin, 620, "bold 30px Arial");
  drawText("cena brez vezave", margin, 660, '17px "Arial Narrow"');

  const qrText = [
    "za več informacij",
    "o cenah in",
    "značilnostih",
    "mobitela",
    "poskenirajte",
    "QR kodo",
  ];

  qrText.forEach((line, index) => {
    drawText(line, 280, 620 + index * 20, '18px "Arial Narrow"');
  });

  try {
    const qrImg = await loadImage("https://example.com/qr-code.png");
    ctx.drawImage(qrImg, 380, 620, 100, 100);
  } catch (error) {
    console.log("Could not load QR code image, skipping...");
  }

  drawText("660,00 €", margin, 730, "bold 30px Arial");
  drawText(
    "najnižja akcijska cena v zadnjih 30 dneh",
    margin,
    770,
    '17px "Arial Narrow"'
  );

  ctx.font = "23px Arial";
  ctx.textAlign = "center";
  drawText("www.telekom.si", 240, 750, "23px Arial");

  const buffer = canvas.toBuffer("image/png");
  const outputPath = "./images/canvas-output.png";

  if (!fs.existsSync("./images")) {
    fs.mkdirSync("./images");
  }

  fs.writeFileSync(outputPath, buffer);
  console.log("Image generated successfully using canvas!");

  const { exec } = require("child_process");
  exec(`open -a Preview ${outputPath}`, (error) => {
    if (error) {
      console.error("Error opening Preview:", error);
    }
  });
}

renderHtmlToCanvas().catch(console.error);
