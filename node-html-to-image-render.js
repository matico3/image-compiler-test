import nodeHtmlToImage from "node-html-to-image";
import { exec } from "child_process";
import { readFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function generateImage(template = "joejuice") {
  const outputPath = `./images/${template}/node-html-to-image.png`;
  const templatePath = join(__dirname, `/templates/${template}.html`);

  try {
    const html = readFileSync(templatePath, "utf8");

    await nodeHtmlToImage({
      output: outputPath,
      puppeteerArgs: {
        // args: [
        //   "--disable-font-antialiasing",
        //   "--disable-smooth-scrolling",
        //   "--font-render-hinting=none",
        // ],
        // defaultViewport: {
        //   width: 480,
        //   height: 800,
        //   deviceScaleFactor: 1,
        // },
      },
      html,
    });

    console.log("Image generated successfully!");

    exec(`open -a Preview ${outputPath}`, (error) => {
      if (error) {
        console.error("Error opening Preview:", error);
      }
    });
  } catch (error) {
    console.error("Error generating image:", error);
  }
}

const template = process.argv[2] || "joejuice";
generateImage(template);
