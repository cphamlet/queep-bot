$(function () {
    // Handler for .ready() called.
    $('#fileUpload').on("change", function () {
        $('#fileUpload[type=file]').parse({
            config: {
                //When a file has completed parsing, it will run the complete function. 
                complete: function complete(results, file) {
                    //Converts 2d Array to json.
                    csvToJSON(results.data);
                }
            },
            //Executes before the file is parsed
            before: function before(file, inputElem) {
                console.log(file);
                if (!file || !file.name.slice(-4)==".csv") {
                    return { action: "abort", reason: "Invalid file, use a CSV file." };
                }
            },
            error: function error(err, file, inputElem, reason) {
                alert(reason);
                // executed if an error occurs while loading the file,
                // or if before callback aborted for some reason
            }
        }); //end Papa.parse();
    }); //end on function
});

function csvToJSON(csv_data) {
    console.log("Load complete");
    word_acro_data = {};
    for (var i = 1; i < csv_data.length - 1; i++) {
        let acronym = RegExp.escape(csv_data[i][0]);
        //TODO, if the spelled out word has a special html char, it will not be 
        //imported properly, need to escape
        let spelledOutWords = csv_data[i][1].split(",");
        for(let i in spelledOutWords){
            spelledOutWords[i] = RegExp.escape(spelledOutWords[i]);
        }
        word_acro_data[acronym] = spelledOutWords;
    }

    triggerAnimation();
}

function triggerAnimation() {
    M.toast({html: 'CSV Uploaded Sucessfully! &#x2713;'});
    return;
}

RegExp.escape = function(S){
    // 1. let str be ToString(S).
    // 2. ReturnIfAbrupt(str).
    let str = String(S);
    // 3. Let cpList be a List containing in order the code
    // points as defined in 6.1.4 of str, starting at the first element of str.
    let cpList = str.split('');
    // 4. let cuList be a new List
    let cuList = [];
    // 5. For each code point c in cpList in List order, do:
    for(var i = 0; i<cpList.length; i++){
      if("^$\\.*+?()[]{}|".indexOf(cpList[i]) !== -1){
        cuList.push("\\");
      }
      cuList.push(cpList[i]);
    }
    //6. Let L be a String whose elements are, in order, the elements of cuList.
    let L = cuList.join("");
    return L;
  }