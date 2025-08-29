const { OrfeedGateway } =require("../feeds/orfeed");

class Feeds {
    constructor(args)
    {
        //console.log("rates:",info.rates);
        this.ORFEED=new OrfeedGateway();
    }
}