const fs=require("fs");
const path=require("path");

const state={
    running:false,
    project:null,
    logs:[]
};

function log(message){
    state.logs.push(String(message));
    if(state.logs.length>100) state.logs.shift();
}

function start(project){
    state.running=true;
    state.project=project||null;
    log("LIVE START");
}

function stop(){
    state.running=false;
    log("LIVE STOP");
}

function inspectHTML(file){
    if(!fs.existsSync(file)) {
        throw new Error("Fichier introuvable: "+file);
    }

    const html=fs.readFileSync(file,"utf8");

    const result={
        type:"html",
        file:path.resolve(file),
        bytes:Buffer.byteLength(html),
        interactive:/<button|onclick=|addEventListener|<input|<form/i.test(html),
        hasScript:/<script/i.test(html),
        hasStyle:/<style|\.css/i.test(html)
    };

    log("LIVE HTML INSPECTED");
    return result;
}

if(require.main===module){
    const file=process.argv[2];

    if(!file){
        console.log("LIVE_ENGINE_READY");
        process.exit(0);
    }

    try{
        start(file);
        console.log(JSON.stringify(inspectHTML(file),null,2));
    }catch(error){
        console.error("LIVE_ERROR="+error.message);
        process.exit(1);
    }
}

module.exports={
    state,
    start,
    stop,
    log,
    inspectHTML
};
