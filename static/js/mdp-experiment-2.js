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

    getNumberSequenceTrials = function(seqLength, numTrials) {
      let trials = []
      for(let i = 0; i < numTrials; i++){
        let trialObj = {}
        let sequence = []
        for(let j = 0; j < seqLength; j++){
          sequence.push(Math.floor(Math.random() * 10))
        }
        trialObj["trial_id"] = "sequence_" + (i+1)
        trialObj["stimulus"] = sequence.join(", ")
        trials.push(trialObj)
      }
      return trials

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

  let stimulus_template = `<br><br>
        Remember the following sequence of numbers. You will be asked to repeat it later. Do not write them down anywhere!
        <br><br>
        <h1>{sequence}</h1>
        <br><br>
        Press <code>space</code> to continue to the Web of Cash round`


  let ready = {
    type: jsPsychHtmlKeyboardResponse,
    choices: [" "],
    stimulus: `<h1> Get ready to start the game! </h1><br><br> Press <code>space</code> to continue`
  };


  let num_trials = 2;
  let mdpTrials = getPracticeTrials(num_trials)
  let numSeqTrials = getNumberSequenceTrials(5, num_trials)
  let combinedTimelineVariables = []

  for(let i = 0; i < num_trials; i++) {
    combinedTimelineVariables.push({
      seq_trial_id: numSeqTrials[i].trial_id,
      stimulus: numSeqTrials[i].stimulus,
      mdp_trial_id: mdpTrials[i].trial_id,
      stateRewards: mdpTrials[i].stateRewards,
      correct_sequence: numSeqTrials[i].stimulus.replace(/[, ;:]/g,""),
      answer_trial_id: "answer_"+ (i+1)
    })
  }
  let trials_timeline = {
    timeline: [
      {
        type: jsPsychHtmlKeyboardResponse,
        choices: [" "],
        data:{
          trial_id: function() {
            return jsPsych.timelineVariable("seq_trial_id")
          }
        },
        stimulus: function(){
          return stimulus_template.replace("{sequence}", jsPsych.timelineVariable("stimulus"))
        }
      },
      {
        type: jsPsychMouselabMDP,
        // display: $('#jspsych-target')
        graph: STRUCTURE.graph,
        layout: STRUCTURE.layout,
        initial: STRUCTURE.initial,
        num_trials: num_trials,
        stateClickCost: function() {
          return COST;
        },
        stateDisplay: 'click',
        stateResetMs: 2000,
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
        lowerMessage: `Click on the nodes to reveal their values.<br>
Move with the arrow keys after you are done clicking.`,
        stateRewards: function() {
          return jsPsych.timelineVariable("stateRewards", true)
        },
        trial_id: function() {
          return jsPsych.timelineVariable("mdp_trial_id")
        },
        trialCount: function() {
          return pracTrialCount;
        },
        on_finish: function() {
          pracTrialCount += 1;
          return SCORE = 0;
        },
      },
      {
        type: jsPsychSurveyText,
        questions: [
          {
            prompt: 'Enter the number sequence that you saw before the latest Web of Cash round (no spaces or commas in between numbers)',
            required: true,
          }
        ],
        data:{
          trial_id: function() {
            return jsPsych.timelineVariable("answer_trial_id")
          }
        }
        ,
        button_label: 'Submit',
        on_finish: (data) => {
          if(data.response.Q0.replace(/ ,;./g,"") === jsPsych.timelineVariable("correct_sequence")){
            data.correct = true;
            return numCorrectSequences += 1;
          } else {
            data.correct = false;
          }
        }
      },
      {
        type: jsPsychHtmlKeyboardResponse,
        trial_duration: 1000,
        data:{
          trial_id: function() {
            return jsPsych.timelineVariable("seq_trial_id")
          }
        },
        stimulus: function(){
          var last_trial_correct = jsPsych.data.get().last(1).values()[0].correct;
          var num_correct = jsPsych.data.get().trials.filter(trial => ("correct" in trial) && (trial.correct)).length;

          var num_complete = pracTrialCount;
          var scoreText = `<br><br>Your current score for the sequence task is <b>${num_correct}/${num_complete}</b>.`
          if(last_trial_correct){
            return "<br><br><h1 style='color:green'>Correct!</h1>" + scoreText;
          } else {
            return "<br><br><h1 style='color:red'>Wrong!</h1>" + scoreText;
          }

        }
      },
    ],
    timeline_variables: combinedTimelineVariables,
    on_timeline_start: function() {
       pracTrialCount = 0;
       numCorrectSequences = 0;
    },
    on_timeline_finish: function() {
      console.log("Timeline finished")
      jsPsych.data.addProperties({
        num_correct_sequences: numCorrectSequences
      });
      jsPsych.data.displayData()
    }
  }


  // ================================================ #
  // ========= TIMELINE LOGIC ======================= #
  // ================================================ #

  let experiment_timeline = [ready, trials_timeline];


  // ================================================ #
  // ========= START AND END THE EXPERIMENT ========= #
  // ================================================ #


  // initialize jspsych experiment -- without this nothing happens
  return jsPsych.run(experiment_timeline);
};
