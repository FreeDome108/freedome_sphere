const { info } =require("../const/info");

let currencies_replace=info.aliases;

global.getVolumeQA=(orders, amount)=>
{
    let gAmount=0;
    let gQuantity=0;

    orders.every(function(order, index) {
        let nAmount=amount-gAmount;
        let p=parseFloat(order[0]);
        let q=parseFloat(order[1]);
        let a=parseFloat(order[2]);

        if (nAmount<=a)
        {
            gQuantity+=nAmount/p; 
            gAmount+=nAmount;

            return false
        }
        gAmount+=a;
        gQuantity+=q;
        return true;
    })
    
    return {quantity:gQuantity,amount:gAmount};
}

global.getVolumeQAq=(orders, quantity)=>
{
    let gAmount=0;
    let gQuantity=0;

    orders.every(function(order, index) {
        let nQuantity=quantity-gQuantity;
        let p=parseFloat(order[0]);
        let q=parseFloat(order[1]);
        let a=parseFloat(order[2]);

        if (nQuantity<=q)
        {
            gQuantity+=nQuantity;
            gAmount+=p*nQuantity;

            return false
        }
        gAmount+=p*q;
        gQuantity+=q;
        return true;
    })
    
    return {quantity:gQuantity,amount:gAmount};
}


global.getVolumePQA=(orders,amount)=>
{
    if (amount==0) return orders[0][0];
    let QA=getVolumeQA(orders, amount);
    QA.price=QA.amount/QA.quantity;
    return QA;
}

global.initVolumes=(sym,cur)=>
{
  Object.keys(sym).forEach(function (key) {
      sym[key].volumes=VOLUMES.map((n)=>(n/cur[sym[key].quote].usdPrice))
  })
  return sym;
}






//Переименовать валюты
function rates_rename(rates)
{
    for (const rateKey of Object.keys(rates)) {
    //Object.keys(rates).forEach(function (rateKey) {
        //console.log("!!!!");
        //console.log(rates[rateKey]);
        for (const pairKey of Object.keys(rates[rateKey])) {
        //Object.keys(rates[rateKey]).forEach(function (pairKey) {
            if (rates[rateKey][pairKey].pair1 in currencies_replace)
            {
                let from=rates[rateKey][pairKey].pair1;
                let to=currencies_replace[from].to;
                let rate=currencies_replace[from].rate;
                
                rates[rateKey][pairKey].pair1=to;
                rates[rateKey][pairKey].bid*=rate;
                rates[rateKey][pairKey].ask*=rate;
            }
            
            if (rates[rateKey][pairKey].pairN in currencies_replace)
            {
                let from=rates[rateKey][pairKey].pairN;
                let to=currencies_replace[from].to;
                let rate=currencies_replace[from].rate;
                
                rates[rateKey][pairKey].pairN=to;
                rates[rateKey][pairKey].bid/=rate;
                rates[rateKey][pairKey].ask/=rate;
            }
        }
        //console.log("!!!!222222");
        //console.log(rates[rateKey]);
    }
    return rates;
}


//Проверить котировки
//if bid<ask - в котировках перепутаны ask/bid

//Отобразить котировки


/*


Простые задачи:

Отобразить курс на разных биржах
*/
function rate_show(rateKey,rate)
{
    console.log(rateKey,rate);
}

function rates_show(rates, pair1, pairN)
{
    console.log("rates_show",pair1+"/"+pairN);

    Object.keys(rates).forEach(function (rateKey) {
        Object.keys(rates[rateKey]).forEach(function (pairKey) {
            let rate=rates[rateKey][pairKey];
            if ((rate.pair1==pair1)&&(rate.pairN==pairN)) rate_show(rateKey,rate);
            if ((rate.pairN==pair1)&&(rate.pair1==pairN)) rate_show(rateKey,rate);
        });
    });
}


function get_rate(rates, from, to)
{
    let res=[];
    for (const rateKey of Object.keys(rates)) {
        for (const pairKey of Object.keys(rates[rateKey])) {
                let pair=rates[rateKey][pairKey];
                if ((pair.pair1==from)&&(pair.pairN==to)) {res.push({gateway: rateKey,bid: pair.bid,ask:pair.ask}  )};
                if ((pair.pair1==to)&&(pair.pairN==from)) {res.push({gateway: rateKey,bid: 1/pair.ask,ask:1/pair.bid}  )};
        }
    }
    return res;
}
/*
как самым лучшим образом купить валюту to из валюты from, через третью валюту. Закрытием открытых заявок
*/
function best_rates_cross_show(rates, from, to, cross_array)
{
    console.log("==========");
    console.log("best_rates_cross_show",from+" => "+to);
    let r=get_rate(rates,from,to);
            for (const i of Object.keys(r))
            {
                let bid=r[i].bid;
                let ask=r[i].ask;
                console.log({g:r[i].gateway,bid:bid,ask:ask});
                console.log({g:r[i].gateway,bid:1/bid,ask:1/ask});
            }

    for (const cross of Object.values(cross_array))
    {
        console.log("best_rates_cross_show",from+" => "+cross+" =>"+to);
        let r1= get_rate(rates,from,cross);
        let r2=get_rate(rates,cross,to);

        for (const i1 of Object.keys(r1))
        {
            console.log("---");
            for (const i2 of Object.keys(r2))
            {
                
                let bid=r1[i1].bid*r2[i2].bid;
                let ask=r1[i1].ask*r2[i2].ask;
                //console.log(r1[i1]);
                //console.log(r2[i2]);
                //console.log({g:r1[i1].gateway+"->"+r2[i2].gateway,bid:bid,ask:ask});
                console.log({g:r1[i1].gateway+"->"+r2[i2].gateway,bid:1/bid,ask:1/ask});
            }
        }
        //console.log(r1,r2);
    }
}

/*
Как самым выгодным способом обменять RUR -> BTC
Отобразить варианты обмена и стоимости. С учетом кросс-курса моментального
*/

function best_path_find(typefrom, curFrom, typeTo, CurTo)
{


}



module.exports = {
    rates_show:rates_show,
    rates_rename:rates_rename,
    get_rate,
    best_path_find,
    best_rates_cross_show,
}

