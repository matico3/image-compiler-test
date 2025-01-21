import puppeteer from "puppeteer";
import { writeFile, mkdir } from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

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

const OPEN_AFTER_CREAATE = false;
async function renderWithPuppeteer(template = "joejuice") {
  try {
    const browser = await puppeteer.launch({
      // args: [
      //   "--disable-font-antialiasing",
      //   "--disable-smooth-scrolling",
      //   "--font-render-hinting=none",
      //   "--disable-gpu",
      //   "--font-antialiasing=none",
      //   "--disable-lcd-text",
      // ],
      defaultViewport: {
        width: options.width,
        height: options.height,
        deviceScaleFactor: 1,
      },
    });
    const version = await browser.version();
    console.log("Chromium version:", version);
    const page = await browser.newPage();
    const templatePath = path.join(__dirname, `/templates/${template}.html`);
    await page.goto("file://" + templatePath);

    const imageBuffer = await page.screenshot({
      fullPage: true,
      type: "png",
    });

    await browser.close();

    const outputDir = `./images/${template}`;
    await mkdir(outputDir, { recursive: true });

    await writeFile(`./images/${template}/puppeteer-rendered.png`, imageBuffer);
    console.log(
      "Image has been rendered successfully to puppeteer-rendered.png"
    );

    // if (OPEN_AFTER_CREAATE) {
    //   exec(
    //     `open -a Preview ./images/${template}/puppeteer-rendered.png`,
    //     (error) => {
    //       if (error) {
    //         console.error("Error opening Preview:", error);
    //       }
    //     }
    //   );
    // }
  } catch (error) {
    console.error("Error during rendering:", error);
    process.exit(1);
  }
}

const template = process.argv[2] || "joejuice";
renderWithPuppeteer(template);
