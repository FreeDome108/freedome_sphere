const axios = require('axios');

const yandexApiKey = 'YOUR_YANDEX_API_KEY';
const googleApiKey = 'YOUR_GOOGLE_API_KEY';
const baiduApiKey = 'YOUR_BAIDU_API_KEY';

const languageList = ['en','ru','th',];

const translate = async (text, sourceLanguageCode, targetLanguageCode) => {
  const yandexResponse = await axios.get(
    `https://translate.yandex.net/api/v1.5/tr.json/translate?key=${yandexApiKey}&text=${text}&lang=${sourceLanguageCode}-${targetLanguageCode}`
  );
  const googleResponse = await axios.get(
    `https://translation.googleapis.com/language/translate/v2?key=${googleApiKey}&source=${sourceLanguageCode}&target=${targetLanguageCode}&q=${text}`
  );
  const baiduResponse = await axios.get(
    `https://api.fanyi.baidu.com/api/trans/vip/translate?q=${text}&from=${sourceLanguageCode}&to=${targetLanguageCode}&appid=${baiduApiKey}`
  );

  return [yandexResponse.data.text[0], googleResponse.data.translations[0].translatedText, baiduResponse.data.trans_result[0].dst];
};

const translateText = async (sourceLanguageCode, targetLanguageCode, contents) => {
  //contents - can be array


  const translations = await Promise.all(
    contents.map(text => translate(text, sourceLanguageCode, targetLanguageCode))
  );

  return translations.map(([yandexText, googleText, baiduText], i) => ({
    translatedText: yandexText,
    detectedSourceLanguage: sourceLanguageCode
  }));
};

module.exports = { translateText };





const yandexTranslate = require('yandex-translate');
const googleTranslate = require('@google-cloud/translate');
const BaiduTranslate = require('baidu-translate-api');
const crc = require('crc');
const fs = require('fs');

// Initialize the translate clients
const yandexClient = new yandexTranslate('YOUR_YANDEX_API_KEY');
const googleClient = new googleTranslate.Translate();
const baiduClient = new BaiduTranslate('YOUR_BAIDU_APP_ID', 'YOUR_BAIDU_SECRET_KEY');

// Set the default translation service to use
const defaultTranslationService = 'yandex';

// Create a cache for storing translated text
const cache = {};

// Background function for handling translation requests
async function translateText(sourceLanguageCode, targetLanguageCode, contents) {
  // Check if the translation is already in the cache
  const cacheKey = crc.crc32(sourceLanguageCode + targetLanguageCode + contents.join('')).toString(16);
  if (cache[cacheKey]) {
    return cache[cacheKey];
  }

  // Otherwise, perform the translation
  let translations;
  switch (defaultTranslationService) {
    case 'yandex':
      translations = await yandexClient.translate(contents, { from: sourceLanguageCode, to: targetLanguageCode });
      break;
    case 'google':
      translations = await googleClient.translate(contents, targetLanguageCode, { from: sourceLanguageCode });
      break;
    case 'baidu':
      translations = await baiduClient.translate(contents, { from: sourceLanguageCode, to: targetLanguageCode });
      break;
  }

  // Store the translations in the cache
  cache[cacheKey] = translations;

  // Write the cache to a file
  fs.writeFileSync(`cache/${cacheKey}.${targetLanguageCode}`, JSON.stringify(translations));

  return translations;
}

module.exports = {
  translateText,
};