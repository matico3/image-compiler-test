import puppeteer from "puppeteer";
import { writeFile } from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";
import { exec } from "child_process";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// const options = {
//   width: 480,
//   height: 800,
// };
const options = {
  width: 296,
  height: 128,
};

(async () => {
  try {
    const browser = await puppeteer.launch({
      args: [
        "--disable-font-antialiasing",
        "--disable-smooth-scrolling",
        "--font-render-hinting=none",
      ],
    });
    const page = await browser.newPage();
    await page.setViewport({
      height: options.height,
      width: options.width,
    });

    const templatePath = path.join(__dirname, "/templates/joejuice.html");
    await page.goto("file://" + templatePath);

    const imageBuffer = await page.screenshot({
      fullPage: true,
      type: "png",
    });

    await browser.close();

    await writeFile("puppeteer-rendered.png", imageBuffer);
    console.log(
      "Image has been rendered successfully to puppeteer-rendered.png"
    );

    exec(`open -a Preview puppeteer-rendered.png`, (error) => {
      if (error) {
        console.error("Error opening Preview:", error);
      }
    });
  } catch (error) {
    console.error("Error during rendering:", error);
    process.exit(1);
  }
})();
