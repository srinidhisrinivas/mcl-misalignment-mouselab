let DEBUG = true;

let NUM_TRIALS = 30;

let getStroopTrials = void 0;

jsPsych = initJsPsych({
  display_element: 'jspsych-target',
  on_finish: function() {
    if (DEBUG) {
      return jsPsych.data.displayData();
    }
  },
  override_safe_mode: true
});

$(window).on('beforeunload', function() {
  return 'Are you sure you want to leave?';
});

$(window).resize(function() {
  return checkWindowSize(800, 600, $('#jspsych-target'));
});

$(window).resize();

$(window).on('load', function() {
  var loadTimeout, slowLoad;
  // Load data and test connection to server.
  slowLoad = function() {
    var ref;
    return (ref = $('slow-load')) != null ? ref.show() : void 0;
  };
  loadTimeout = delay(12000, slowLoad);

  return delay(300, function() {
    COST = 1;
    PARAMS = {
      CODE: "C6DMOQA6",
      MIN_TIME: 7,
      inspectCost: COST,
      startTime: Date(Date.now()),
      variance: '2_4_24',
      branching: '312'
    };
    COST_EXPLANATION = "Some nodes may require more clicks than others.";
    COST_EXPLANATION = "Some nodes may require more clicks than others.";
    if (PARAMS.variance) {
      id = `${PARAMS.branching}_${PARAMS.variance}`;
    } else {
      id = `${PARAMS.branching}`;
    }

    getPracticeTrials = function(numTrials) {
      var idx_2, l, len, m, ref2, reward, templateTrial, trialObj, trials;
      templateTrial = TRIALS[0]["stateRewards"];
      trials = [];
      for (i = l = 0, ref2 = numTrials; (0 <= ref2 ? l < ref2 : l > ref2); i = 0 <= ref2 ? ++l : --l) {
        trialObj = {};
        trialObj["trial_id"] = "practice_" + (i + 1);
        trialObj["stateRewards"] = [];
        for (idx_2 = m = 0, len = templateTrial.length; m < len; idx_2 = ++m) {
          reward = templateTrial[idx_2];
          if (idx_2 > 0) {
            trialObj["stateRewards"].push(_.sample([-10.0, 10.0]));
          } else {
            trialObj["stateRewards"].push(0.0);
          }
        }
        trials.push(trialObj);
      }
      return trials;
    };

    createStartButton();
    return clearTimeout(loadTimeout);
  });
});

createStartButton = function() {
  initializeExperiment();
};

initializeExperiment = function() {

  $('#jspsych-target').html('');
  //  ============================== #
  //  ========= EXPERIMENT ========= #
  //  ============================== #

  let ready = {
    type: jsPsychHtmlKeyboardResponse,
    choices: [" "],
    stimulus: `<h1> Get ready to start the game! </h1>`
  };
  let num_trials = 5;
  let practice_trials = {
    type: jsPsychMouselabMDP,
    // display: $('#jspsych-target')
    graph: STRUCTURE.graph,
    layout: STRUCTURE.layout,
    initial: STRUCTURE.initial,
    num_trials: num_trials,
    stateClickCost: function() {
      return COST;
    },
    minTime: 10,
    stateDisplay: 'click',
    stateResetMs: 5000,
    accumulateReward: true,
    wait_for_click: true,
    withholdReward: false,
    scoreShift: 2,
    stateBorder: function() {
      return "rgb(187,187,187,1)"; //getColor
    },
    revealOnArrive: false,
    forbidReclick: true,
    highlightClicked: true,
    // playerImage: 'static/images/spider.png',
    playerImage: 'https://freepngimg.com/thumb/spider/15-black-spider-siluet-logo-png-image.png',
    // trial_id: jsPsych.timelineVariable('trial_id',true)
    blockName: 'test',
    upperMessage: "Web of Cash - Practice Round",
    nextClickTimeLimit: 5,
//     lowerMessage: `Click on the nodes to reveal their values.<br>
// Move with the arrow keys after you are done clicking.`,
    timeline: getPracticeTrials(num_trials),
    trialCount: function() {
      return pracTrialCount;
    },
    on_finish: function() {
      pracTrialCount += 1;
      return SCORE = 0;
    },
    on_timeline_start: function() {
      return pracTrialCount = 0;
    },
    on_timeline_finish: function() {
      jsPsych.data.displayData()
    }
  };
  // ================================================ #
  // ========= TIMELINE LOGIC ======================= #
  // ================================================ #



  let experiment_timeline = [ready, practice_trials];


  // ================================================ #
  // ========= START AND END THE EXPERIMENT ========= #
  // ================================================ #


  // initialize jspsych experiment -- without this nothing happens
  return jsPsych.run(experiment_timeline);
};
