const { comissions,moves } = require("./gateways")
const { rates } = require("./rates")
const { aliases } = require("./symbols")

let info={
    comissions:comissions,
    moves:moves,
    rates:rates,
    aliases:aliases
};

module.exports = {
    info:info,
}