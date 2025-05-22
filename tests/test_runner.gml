function runTests() {
    var tests = [helloWorldTest];
    var results = [];

    for (var i = 0; i < tests.length; i++) {
        var result = tests[i]();
        results.push(result);
    }

    reportResults(results);
}

function reportResults(results) {
    for (var i = 0; i < results.length; i++) {
        if (results[i].passed) {
            show_message("Test " + results[i].name + " passed.");
        } else {
            show_message("Test " + results[i].name + " failed: " + results[i].error);
        }
    }
}

function setup() {
    // Setup code here
}

function teardown() {
    // Teardown code here
}

runTests();