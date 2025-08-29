const fs = require('fs');

const LOG_DIR="logs/";
const LOG_DIR_M="logs/m/";
const VERBOSE_FILENAME="logs/verb.log";
const FULL_FILENAME="logs/full.log";
const ERROR_FILENAME="logs/error.log";

class Log {

  constructor(NAME,VERBOSE_LEVEL,DEBUG_LEVEL,ERROR_LEVEL) {
    this.NAME=NAME;
    this.VERBOSE_LEVEL=VERBOSE_LEVEL;
    this.DEBUG_LEVEL=DEBUG_LEVEL;
    this.ERROR_LEVEL=ERROR_LEVEL;
  }
  
  verb(level,msg) {
    if (level<=this.VERBOSE_LEVEL)
      console.log(msg);
      if (typeof msg!="string") msg=JSON.stringify(msg);
      fs.appendFileSync(VERBOSE_FILENAME, `\n${this.NAME}  ${msg}`);
      fs.appendFileSync(FULL_FILENAME, `\n${this.NAME}  ${msg}`);

      fs.appendFileSync(LOG_DIR_M+this.NAME+".verb", `\n${this.NAME}  ${msg}`);
      fs.appendFileSync(LOG_DIR_M+this.NAME+".full", `\n${this.NAME}  ${msg}`);

  }

  debug(level,msg) {
    if (typeof msg!="string") msg=JSON.stringify(msg);
    if (level<=this.DEBUG_LEVEL)
      fs.appendFileSync(FULL_FILENAME, `\n${this.NAME}  ${msg}`);

      fs.appendFileSync(LOG_DIR_M+this.NAME+".full", `\n${this.NAME}  ${msg}`);

  }
  error(level,msg) {
    if (level<=this.ERROR_LEVEL)
      console.log(msg);
      if (typeof msg!="string") msg=JSON.stringify(msg);
      fs.appendFileSync(VERBOSE_FILENAME, `\n${this.NAME}  ${msg}`);
      fs.appendFileSync(ERROR_FILENAME, `\n${this.NAME}  ${msg}`);
      fs.appendFileSync(FULL_FILENAME, `\n${this.NAME}  ${msg}`);

      fs.appendFileSync(LOG_DIR_M+this.NAME+".verb", `\n${this.NAME}  ${msg}`);
      fs.appendFileSync(LOG_DIR_M+this.NAME+".full", `\n${this.NAME}  ${msg}`);
      fs.appendFileSync(LOG_DIR_M+this.NAME+".error", `\n${this.NAME}  ${msg}`);

  }

}

module.exports = Log;