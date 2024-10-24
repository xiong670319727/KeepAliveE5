const puppeteer = require('puppeteer');
const except = require('./except.js');
const config = require(process.argv[2]);
const devEnv = process.argv[3];

const puppeteerLaunchOptions = devEnv
  ? {
      headless: false,
      executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe',
    }
  : {
      headless: true,
      args: ['--no-sandbox'],
    };

let browser = { close: async () => {} };
setTimeout(async () => {
  await browser.close();
  except.fatalError(config.username);
}, except.totalTimeout);

const sleep = (seconds) =>
  new Promise((resolve) => setTimeout(resolve, (seconds || 1) * 1000));

(async () => {
  try {
    browser = await puppeteer.launch(puppeteerLaunchOptions);
    const page = await browser.newPage();
    // https://pptr.dev/#?product=Puppeteer&version=v10.4.0&show=api-pagesetdefaulttimeouttimeout
    await page.setDefaultTimeout(except.methodTimeout);
    await page.setDefaultNavigationTimeout(except.methodTimeout);

    await page.goto(
      `https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=${config.client_id}&scope=offline_access%20User.Read&response_type=code&redirect_uri=${config.redirect_uri}`
    );

    // email
    await page.waitForSelector('input[type=email]');
    await page.type('input[type=email]', config.username);
    // next
    await page.waitForSelector('[type=submit]');
    await sleep(1);
    await page.click('[type=submit]');

    // password
    await page.waitForSelector('input[type=password]');
    await page.type('input[type=password]', config.password);
    // login
    await sleep(3);
    await page.waitForSelector('[type=submit]');
    await Promise.all([page.waitForNavigation(), page.click('[type=submit]')]);

    // bypass authenticator recommendation
    let isMoreInfoPage = true;
    await page
      .waitForSelector('[type=checkbox]' /* , { timeout: 10_000 } */)
      .then(() => (isMoreInfoPage = false))
      .catch(() => {});
    if (isMoreInfoPage) {
      // next
      await page.waitForSelector('[type=submit]');
      await Promise.all([
        page.waitForNavigation(),
        page.click('[type=submit]'),
      ]);

      // bypass page
      await page.waitForSelector(
        'a[href*="https://aka.ms/getMicrosoftAuthenticator"]'
      );
      await Promise.all([
        page.waitForNavigation(),
        page.evaluate(() =>
          [...document.querySelectorAll('.ms-Card a')]
            .filter((a) => !a.href)[0]
            .click()
        ),
      ]);
    }

    // consent
    await page.waitForSelector('[type=checkbox]');
    await sleep(1);
    await page.click('[type=checkbox]');

    // accept
    await page.waitForSelector('[type=submit]');
    await page.click('[type=submit]');
    // request redirect uri
    await sleep(3);
    await browser.close();
    process.exit(0);
  } catch (error) {
    await browser.close();
    except.fatalError(config.username, error);
  }
})();
