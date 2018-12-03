$(function() {
    // Handler for .ready() called.
    $('#fileUpload').on("change", function(){ 
        $('#fileUpload[type=file]').parse(
            {
                config: {
                    //When a file has completed parsing, it will run the complete function. 
                    complete:function(results, file){
                        //Converts 2d Array to json.
                        csvToJSON(results.data);
                    }
                },
                //Executes before the file is parsed
                before:function(file, inputElem){
                    if(!file || !file.name.endsWith(".csv")){
                        return {action:"abort", reason:"Invalid file, use a CSV file."};
                    }
                },
                error: function(err, file, inputElem, reason)
                {
                    alert(reason);
                    // executed if an error occurs while loading the file,
                    // or if before callback aborted for some reason
                }
            }
        ); //end Papa.parse();
    }); //end on function
});

function csvToJSON(csv_data){
    console.log("Load complete");
    word_acro_data = {};
    for(var i = 1; i<csv_data.length-1; i++){
        var acronym = csv_data[i][0];
        acronym = $("<div />").text(acronym).html()
        //TODO, if the spelled out word has a special html char, it will not be 
        //imported properly, need to escape
        var spelledOutWords = csv_data[i][1].split(",");
        word_acro_data[acronym] = spelledOutWords;
    }

    triggerAnimation();
}

function triggerAnimation(){
    M.toast({html: 'CSV Uploaded Sucessfully! &#x2713;'});
    return;
}