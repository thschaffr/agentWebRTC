// This is the FINAL production Node.js script. It is called by run.bat.
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');

puppeteer.use(StealthPlugin());

const totalBots = 100;
const concurrencyLimit = 70;

const meetingBaseUrl = "https://22.6.5.94/en-US/meeting/123";
const joinButtonSelector = "._3vkSKa";

const openBrowsers = [];

async function runSingleBot(botId) {
    const botName = `LoadTestBot-${botId}`;
    const fullMeetingUrl = `${meetingBaseUrl}?name=${botName}&videoDisabled=true&audioMuted`;
    let browser;
    try {
        browser = await puppeteer.launch({
            headless: true,
            ignoreHTTPSErrors: true,
            args: [
                '--disable-gpu', '--mute-audio', '--disable-extensions', '--disable-background-networking',
                '--disable-background-timer-throttling', '--disable-backgrounding-occluded-windows',
                '--disable-sync', '--use-fake-ui-for-media-stream', '--use-fake-device-for-media-stream',
                '--autoplay-policy=no-user-gesture-required', '--no-first-run', '--no-sandbox',
                '--disable-dev-shm-usage', '--incognito'
            ]
        });
        openBrowsers.push(browser);
        const page = await browser.newPage();
        await page.setViewport({ width: 1280, height: 720 });
        await page.goto(fullMeetingUrl, { waitUntil: 'domcontentloaded' }).catch(e => {});
        try {
            await page.waitForSelector('#details-button', { timeout: 3000 });
            await page.click('#details-button');
            await Promise.all([
                page.waitForNavigation({ waitUntil: 'domcontentloaded' }),
                page.click('#proceed-link')
            ]);
        } catch (error) {}
        await page.waitForSelector(joinButtonSelector, { visible: true, timeout: 15000 });
        await new Promise(r => setTimeout(r, 250));
        await page.evaluate((selector) => document.querySelector(selector).click(), joinButtonSelector);
    } catch (error) {
        if (error.message.includes('Execution context was destroyed')) {
            console.log(`âœ… Bot ${botId}: Joined lobby (navigation confirmed).`);
        } else {
            console.error(`âŒ Bot ${botId}: FAILED - ${error.message}`);
        }
    } finally {
        await new Promise(resolve => setTimeout(resolve, 300000));
        if (browser) {
            const index = openBrowsers.indexOf(browser);
            if (index > -1) openBrowsers.splice(index, 1);
            await browser.close();
        }
        console.log(`â¹ï¸ Bot ${botId}: Session ENDED.`);
    }
}

async function main() {
    console.log(`--- Starting Load Test for ${totalBots} bots, concurrency ${concurrencyLimit} ---`);
    console.log("--- Press CTRL+C to stop all processes. ---");
    const taskQueue = Array.from({ length: totalBots }, (_, i) => i);
    const worker = async () => {
        while (taskQueue.length > 0) {
            const botId = taskQueue.shift();
            console.log(`ðŸš€ Worker picking up task for Bot ${botId}...`);
            await runSingleBot(botId);
        }
    };
    const workerPromises = [];
    for (let i = 0; i < concurrencyLimit; i++) {
        workerPromises.push(worker());
    }
    await Promise.all(workerPromises);
    console.log("\n--- All bot tasks have been processed. Load Test Finished. ---");
}

async function cleanup() {
    console.log(`\n\nðŸš¨ Exit signal received. Closing ${openBrowsers.length} active browser(s)...`);
    await Promise.allSettled(openBrowsers.map(browser => browser.close()));
    process.exit(0);
}
process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);

main();
