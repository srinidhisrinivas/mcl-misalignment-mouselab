# coffeelint: disable=max_line_length, indentation

DEBUG = false
DEBUG_INSTRUCTIONS = true
DEBUG_SUBMIT = no
TALK = no




if DEBUG
  console.log """
  X X X X X X X X X X X X X X X X X
   X X X X X DEBUG  MODE X X X X X
  X X X X X X X X X X X X X X X X X
  """
  CONDITION = parseInt condition
  #CONDITION = 4
  console.log CONDITION


else
  console.log """
  # =============================== #
  # ========= NORMAL MODE ========= #
  # =============================== #
  """
  CONDITION = parseInt condition
  # TODO: remove this
  CONDITION = 1
  console.log condition

if mode is "{{ mode }}"
  CONDITION = 0

# List of conditions by proportions of trials that are given explicit rewards
COST = 1
TIME_NEXT_CLICK = 3
TIME_NODE_REVEAL = 3
PRACTICE_TIME_NEXT_CLICK = 10
NUM_SEQUENCE_LENGTH = 7
CLICK_DELAY_FNS =
  "control": (depth) -> 1.5 * 1000
  "misaligned": (depth) -> [0, 0, 0, 0, 2.75 * 1000][depth-1]
BASE_COST = 1.4
CLICK_COST_FNS =
  "control": (depth) -> BASE_COST
  "misaligned": (depth) -> [-0.25, 0.35, 0.95, 1.55, 2.15][depth-1]

COST_ANSWERS = ["There is no cost for clicking on nodes.", "The cost for clicking on nodes may vary between nodes.", "The cost is always $2.", "It is less costly to inspect further nodes."]
COST_QUESTION = "Which of the following is true about the cost of clicking on nodes?"
COST_CORRECT = "The cost for clicking on nodes may vary between nodes."
COST_ANSWERS_BASELINE = ["There was no cost for clicking on nodes.", "The cost for clicking on nodes varied between nodes.", "The cost was always $#{BASE_COST}.", "It was less costly to inspect further nodes."]
COST_QUESTION_BASELINE = "Which of the following was true about the cost of clicking on nodes?"
COST_CORRECT_BASELINE = "The cost was always $#{BASE_COST}."

CLICK_TIME_ANSWERS = ["Unlimited time", "10 seconds", "#{TIME_NEXT_CLICK} seconds", "1 second"]
CLICK_TIME_CORRECT = "#{TIME_NEXT_CLICK} seconds"

REPETITIONS = 0 #tracks trials in instructions quiz
MAX_REPETITIONS = 4 #max tries they get at instructions quiz
BONUS = 0
QUESTIONNAIRES = undefined
BLOCKS = undefined
PARAMS = undefined
COST_EXPLANATION = undefined
TRIALS = undefined
STRUCTURE = undefined
CLICK_DEPTHS = undefined
N_TRIAL = undefined
INSTRUCTIONS_FAILED = false
SCORE = 0
CORRECT_SEQ_PCTG = 0
BONUS_RATE = .002

if DEBUG
  NUM_TRIALS = 3
else
  NUM_TRIALS = 25

NUM_TUTORIAL_TRIALS = 2
MAX_AMOUNT = BONUS_RATE*(NUM_TRIALS*(4+8+48)+800)
trialCount = 0
pracTrialCount = 0
numCorrectSequences = 0
calculateBonus = undefined
getCost = undefined
getColor = undefined
colorInterpolation = undefined
getClickCosts = undefined
getTrials = undefined
getPracticeTrials = undefined
getNumberSequenceTrials = undefined
createQuestionnaires = undefined
getStroopTrials = undefined
bonus_text = undefined
early_nodes = undefined
final_nodes = undefined

jsPsych = initJsPsych(
    display_element: 'jspsych-target'
    # Saving data on finishing the experiment
    on_finish: ->
      if DEBUG and not DEBUG_SUBMIT
        jsPsych.data.displayData()
      else
        save_data = ->
          psiturk.saveData
            success: ->
              console.log 'Data saved to psiturk server.'
              if reprompt?
                window.clearInterval reprompt
              await completeExperiment uniqueId # Encountering an error here? Try to use Coffeescript 2.0 to compile.
              psiturk.completeHIT();
            error: -> prompt_resubmit

        prompt_resubmit = ->
          $('#jspsych-target').html """
            <h1>Oops!</h1>
            <p>
            Something went wrong submitting your HIT.
            This might happen if you lose your internet connection.
            Press the button to resubmit.
            </p>
            <button id="resubmit">Resubmit</button>
          """
          $('#resubmit').click ->
            $('#jspsych-target').html 'Trying to resubmit...'
            reprompt = window.setTimeout(prompt_resubmit, 10000)
            save_data()

        psiturk.recordUnstructuredData 'final_score', SCORE
        save_data()

    # Saving data after each trial
    on_data_update: (data) ->
      psiturk.recordTrialData data
      # Send POST request to Heroku based on success or failure of syncing data
      # Currently not sure how to read the JSON information in the received POST request in Heroku
      psiturk.saveData()
)
psiturk = new PsiTurk uniqueId, adServerLoc, mode

saveData = ->
  new Promise (resolve, reject) ->
    timeout = delay 10000, ->
      reject('timeout')

    psiturk.saveData
      error: ->
        clearTimeout timeout
        console.log 'Error saving data!'
        reject('error')
      success: ->
        clearTimeout timeout
        console.log 'Data saved to psiturk server.'
        resolve()

$(window).on 'beforeunload', -> 'Are you sure you want to leave?';
$(window).resize -> checkWindowSize 800, 600, $('#jspsych-target')
$(window).resize()
$(window).on 'load', ->
  # Load data and test connection to server.
  slowLoad = -> $('slow-load')?.show()
  loadTimeout = delay 12000, slowLoad

  psiturk.preloadImages [
    'static/images/spider.png'
    'static/images/web-of-cash-unrevealed.png'
    'static/images/web-of-cash.png'
    'static/images/sticky_nodes.png'
    'static/images/web-of-cash-5-levels.png'
    'static/images/web-of-cash-5-structure.png'
    'static/images/web-of-cash-5-levels-2.png'
    'static/images/web-of-cash-5-revealed.png'
    'static/images/web-of-cash-5-timed.png'
    'static/images/web-of-cash-timed.png'
  ]


  delay 300, ->
    console.log 'Loading data'
    PARAMS =
      CODE : "C6DMOQA6"
      MIN_TIME : 14
      inspectCost: COST
      startTime: Date(Date.now())
      bonusRate: BONUS_RATE
      variance: '1_2_4_8_44'
      branching: '31123'

    COST_EXPLANATION = "Some nodes may require more clicks than others."

    psiturk.recordUnstructuredData 'params', PARAMS

    if PARAMS.variance
      id = "#{PARAMS.branching}_#{PARAMS.variance}"
    else
      id = "#{PARAMS.branching}"

    QUESTIONNAIRES = loadJson "static/questionnaires/example.txt"
    STRUCTURE = loadJson "static/json/structure/#{id}.json"
    TRIALS = loadJson "static/json/rewards/#{id}.json"
    CLICK_DEPTHS = loadJson "static/json/structure/#{id}_click_depths.json"
    console.log "loaded #{TRIALS?.length} trials"

    # Create practice mouselab trials
    getPracticeTrials = (numTrials) ->
      templateTrial = TRIALS[0]["stateRewards"]
      trials = []
      for i in [0...numTrials]
        trialObj = {}
        trialObj["trial_id"] = "practice_" + (i+1)
        trialObj["stateRewards"] = []
        for reward, idx_2 in templateTrial
          if idx_2 > 0
            trialObj["stateRewards"].push(_.sample([-10.0, 10.0]))
          else
            trialObj["stateRewards"].push(0.0)
        trials.push(trialObj)
      return trials

    getNumberSequenceTrials = (seqLength, numTrials) ->
      trials = []
      for i in [0...numTrials]
        sequence = []
        trialObj = {}
        for j in [0...seqLength]
          foundNewDigit = false
          while not foundNewDigit
            newDigit = Math.floor(Math.random() * 10)
            if newDigit in sequence
              continue
            else
              sequence.push(newDigit)
              foundNewDigit = true

        trialObj["trial_id"] = "sequence_" + (i+1)
        trialObj["stimulus"] = sequence.join(", ")
        trials.push(trialObj)
      return trials

    # Create test trials for mouselab
    getTrials = (numTrials) ->
      shuffledTrials = _.shuffle TRIALS
      finalTrials = JSON.parse JSON.stringify shuffledTrials.slice(0, numTrials)
      for i in [0...numTrials]
        finalTrials[i].trial_id = "mdp_trial_" + (i+1)
      return finalTrials

    if TALK
      createStartButton()
      clearTimeout loadTimeout
    else
      saveData()
        .then ->
          clearTimeout loadTimeout
          delay 500, createStartButton()
        .catch ->
          clearTimeout loadTimeout
          $('#data-error').show()

bonus_text = (long) ->
    # if PARAMS.bonusRate isnt .01
    #   throw new Error('Incorrect bonus rate')
    s = "<strong>you will earn 1 cent for every $5 you make in the game.</strong>"
    if long
      s += " For example, if your final score is $1000, you will receive a bonus of $2."
    return s


createStartButton = ->
  initializeExperiment()
  return

# Setting up the jsPsych experiment
initializeExperiment = ->
  $('#jspsych-target').html ''

  #  ============================== #
  #  ========= EXPERIMENT ========= #
  #  ============================== #

  # Timeline elements for condition where node values disappear and there is a time limit to click next node
  task_control = {
    "experiment_time_mins": 35
  }

  # Timeline elements for condition where there is a concurrent memory task
  task_misaligned = {
    "experiment_time_mins": 35
  }

  # Opening instructions for each condition
  task_control["experiment_instructions"] = {
    type: jsPsychInstructions
    on_start: () ->
      psiturk.finishInstructions() #started instructions, so no longer worth keeping in database
    show_clickable_nav: true
    data:
      trial_id: "exp_instructions_control"
    pages: -> [
      """
        <h1> Instructions </h1>

        In this HIT, you will play #{NUM_TRIALS} rounds of the <em>Web of Cash</em> game.
        <br> <br>

        First you will be given the instructions and answer some questions to check your understanding of the game.

        <br><br>
        If you complete the entire experiment, you will receive a bonus payment for your performance in this game. The better you perform, the higher your bonus will be. The whole HIT will last around #{task_control["experiment_time_mins"]} minutes.

        <br><br>

        <strong>NOTE: </strong> Please complete the experiment within one sitting without closing or refreshing the page. If you do either of these, you will no longer be able to get back into the experiment to complete it.

      """
    ]
  }
  task_misaligned["experiment_instructions"] = {
    type: jsPsychInstructions
    on_start: () ->
      psiturk.finishInstructions() #started instructions, so no longer worth keeping in database
    show_clickable_nav: true
    data:
      trial_id: "exp_instructions_misaligned"
    pages: -> [
      """
        <h1> Instructions </h1>

        In this HIT, you will play #{NUM_TRIALS} rounds of the <em>Web of Cash</em> game.
        <br> <br>

        First you will be given the instructions and answer some questions to check your understanding of the game.

        <br><br>
        If you complete the entire experiment, you will receive a bonus payment for your performance in this game. The better you perform, the higher your bonus will be. The whole HIT will last around #{task_misaligned["experiment_time_mins"]} minutes.

        <br><br>

        <strong>NOTE: </strong> Please complete the experiment within one sitting without closing or refreshing the page. If you do either of these, you will no longer be able to get back into the experiment to complete it.

      """
    ]
  }

  # Mouselab instructions for each conditions
  task_control["mouselab_instructions_1"] = {
    type: jsPsychInstructions
    data:
      trial_id: "mouselab_instructions_1_control"
    show_clickable_nav: true
    pages: -> [

      """
        <h1>The Spider Web</h1>

        In the <em>Web of Cash</em> game you will guide a money-loving spider through a spider web. Your goal is to travel from the start of the web to the end of the web in five moves. After you make the moves, you will receive a score for the path that you chose to take from start to finish.
        <br><br>
        On your way from start to finish, you will pass through the <em>nodes</em> (gray circles) of the spider web. The spider starts at the node in the middle of the web, and must be moved to any one of the eighteen nodes at the edge of the web, which are five steps away from the starting node.

        Each of these nodes has a certain value, and the numbers present <strong>at the nodes that the spider walks through from start to finish</strong> are relevant to your score for the round. Once you finish a round, the score that you received for the path that you chose will be displayed.

        <br><br>
        <strong>Your objective on each round is to get the highest score possible</strong>. The cumulative score from all the individual rounds will be your final score at the end of the game. The higher your final score at the end of the game, the higher your HIT bonus will be.
        <br><br>
        You will be able to move the spider with the arrow keys, but only in the direction
        of the arrows between the nodes. The image below shows the shape of all the webs that you will be navigating in when the game starts.

       <img class='display' style="width:50%; height:auto" src='static/images/web-of-cash-5-structure.png'/>

      """

      """
        <h1> <em>Web of Cash</em> (1/3) - Node Inspector</h1>

        Initially, the numbers present at the nodes are hidden, so it's hard to make a good decision about which path to choose when you can't see the numbers at the nodes!
        Fortunately, in the <em>Web of Cash</em> game you will have access to a <strong><em>node inspector</em></strong> which can reveal
        the value of any node for #{TIME_NODE_REVEAL} seconds, before it disappears again. Once you reveal the value of a node, it will be highlighted with a black border, and you cannot click on that node again to reveal its value once more.

        <br><br> When using the <strong><em>node inspector</em></strong>, you have to be quick! After each click, you will have #{TIME_NEXT_CLICK} seconds to make the next click. If you do not make the next click in this much time, the node inspector will be disabled for the round, and you will have to start moving the spider.
        <br><br> Once you have finished using the node inspector, you must move the spider using the arrow keys along the path you chose. You do not need to reveal a node's value to walk through it, but its value will still impact your score.
        <br><br>
        To use the node inspector, you must <strong><em>click on a node</em></strong>. The image below illustrates how this works.
        <br><br>
        The node inspector costs a certain amount to reveal a node. This cost may vary between nodes. The fee will be instantly deducted from the spider's money (your score) for that round. Furthermore, there will be a short delay between the time you click on the score and the time that the node is revealed. This may also vary between nodes.
        <br><br>
        <strong>Note:</strong> you can only use the node inspector when you're on the starting
        node. Once you start moving, you can no longer inspect any nodes.

        <img class='display' style="width:50%; height:auto" src='static/images/web-of-cash-5-timed.png'/>


      """


      """
        <h1> Web of Cash</em> (2/3) - Rewards and Costs </h1>

        <img class='display' style="width:50%; height:auto" src='static/images/web-of-cash-5-revealed.png'/>
        <div style="text-align: left">
        <li>You will be able to use the node inspector in each round.</li>
        <li>You will have to click on the starting node before a round starts.</li>
        <li>The timer to make the first click will begin as soon as you click on the starting node.</li>
        <li>In each round, you can see the score for that round in the top right corner.</li>
        <li>At the end of the round, you will be told what your score for that round is.</li>
        </div>
      """

      """
        <h1> Practice Rounds </h1>
        <div style='text-align: left;'>
        <br><br>
        To help you understand the game, it would be helpful to have some practice rounds. The following two rounds will give you a chance to practice playing the game.
        <br> <br>
        However, the practice rounds will differ from the actual rounds of the game in some important respects: <br><br>
        <ol>
          <li>the values at the nodes have the same magnitude (either $10 or $-10). This will <strong>NOT</strong> be the case in the actual rounds, and <strong>the values of the nodes in the actual game will instead vary between the nodes.</strong></li>
          <li>the cost to use the node inspector is fixed at $0.50. This will <strong>NOT</strong> be the case in the actual rounds, and <strong>the cost of the nodes in the actual game may vary between the nodes.</strong></li>
          <li>the delay to reveal the node value is fixed at 0.5 seconds. This will <strong>NOT</strong> be the case in the actual rounds, and <strong>the delay in the actual game may vary between the nodes.</strong></li>
          <li>the time you have to make each click will be #{PRACTICE_TIME_NEXT_CLICK} seconds in the practice rounds. In the actual rounds, the time limit will be <strong>#{TIME_NEXT_CLICK} seconds</strong> instead</li>
        </ol>

        <br><br>
        The score you receive on these practice rounds will <b>NOT</b> count towards your final score for this game.
        <br><br>
        </div>
        Click 'Next' to start with the practice rounds.
        """

    ]
  }
  task_misaligned["mouselab_instructions_1"] = {
    type: jsPsychInstructions
    data:
      trial_id: "mouselab_instructions_1_misaligned"
    show_clickable_nav: true
    pages: -> [

      """
        <h1>The Spider Web</h1>

        In the <em>Web of Cash</em> game you will guide a money-loving spider through a spider web. Your goal is to travel from the start of the web to the end of the web in five moves. After you make the moves, you will receive a score for the path that you chose to take from start to finish.
        <br><br>
        On your way from start to finish, you will pass through the <em>nodes</em> (gray circles) of the spider web. The spider starts at the node in the middle of the web, and must be moved to any one of the eighteen nodes at the edge of the web, which are five steps away from the starting node.

        Each of these nodes has a certain value, and the numbers present <strong>at the nodes that the spider walks through from start to finish</strong> are relevant to your score for the round. Once you finish a round, the score that you received for the path that you chose will be displayed.

        <br><br>
        <strong>Your objective on each round is to get the highest score possible</strong>. The cumulative score from all the individual rounds will be your final score at the end of the game. The higher your final score at the end of the game, the higher your HIT bonus will be.
        <br><br>
        You will be able to move the spider with the arrow keys, but only in the direction
        of the arrows between the nodes. The image below shows the shape of all the webs that you will be navigating in when the game starts.

       <img class='display' style="width:50%; height:auto" src='static/images/web-of-cash-5-structure.png'/>

      """

      """
        <h1> <em>Web of Cash</em> (1/3) - Node Inspector</h1>

        Initially, the numbers present at the nodes are hidden, so it's hard to make a good decision about which path to choose when you can't see the numbers at the nodes!
        Fortunately, in the <em>Web of Cash</em> game you will have access to a <strong><em>node inspector</em></strong> which can reveal
        the value of any node for #{TIME_NODE_REVEAL} seconds, before it disappears again. Once you reveal the value of a node, it will be highlighted with a black border, and you cannot click on that node again to reveal its value once more.

        <br><br> When using the <strong><em>node inspector</em></strong>, you have to be quick! After each click, you will have #{TIME_NEXT_CLICK} seconds to make the next click. If you do not make the next click in this much time, the node inspector will be disabled for the round, and you will have to start moving the spider.
        <br><br> Once you have finished using the node inspector, you must move the spider using the arrow keys along the path you chose. You do not need to reveal a node's value to walk through it, but its value will still impact your score.
        <br><br>
        To use the node inspector, you must <strong><em>click on a node</em></strong>. The image below illustrates how this works.
        <br><br>
        The node inspector costs a certain amount to reveal a node. This cost may vary between nodes, and you sometimes may even receive a reward for clicking on a node. The fee (or reward) will be instantly deducted from (or added to) the spider's money (your score) for that round. Furthermore, there will be a short delay between the time you click on the score and the time that the node is revealed. This may also vary between nodes.
        <br><br>
        <strong>Note:</strong> you can only use the node inspector when you're on the starting
        node. Once you start moving, you can no longer inspect any nodes.

        <img class='display' style="width:50%; height:auto" src='static/images/web-of-cash-5-timed.png'/>


      """


      """
        <h1> Web of Cash</em> (2/3) - Rewards and Costs </h1>

        <img class='display' style="width:50%; height:auto" src='static/images/web-of-cash-5-revealed.png'/>
        <div style="text-align: left">
        <li>You will be able to use the node inspector in each round.</li>
        <li>You will have to click on the starting node before a round starts.</li>
        <li>The timer to make the first click will begin as soon as you click on the starting node.</li>
        <li>In each round, you can see the score for that round in the top right corner.</li>
        <li>At the end of the round, you will be told what your score for that round is.</li>
        </div>
      """

      """
        <h1> Practice Rounds </h1>
        <div style='text-align: left;'>
        <br><br>
        To help you understand the game, it would be helpful to have some practice rounds. The following two rounds will give you a chance to practice playing the game.
        <br> <br>
        However, the practice rounds will differ from the actual rounds of the game in some important respects: <br><br>
        <ol>
          <li>the values at the nodes have the same magnitude (either $10 or $-10). This will <strong>NOT</strong> be the case in the actual rounds, and <strong>the values of the nodes in the actual game will instead vary between the nodes.</strong></li>
          <li>the cost to use the node inspector is fixed at $0.50. This will <strong>NOT</strong> be the case in the actual rounds, and <strong>the cost of the nodes in the actual game may vary between the nodes.</strong></li>
          <li>the delay to reveal the node value is fixed at 0.5 seconds. This will <strong>NOT</strong> be the case in the actual rounds, and <strong>the delay in the actual game may vary between the nodes.</strong></li>
          <li>the time you have to make each click will be #{PRACTICE_TIME_NEXT_CLICK} seconds in the practice rounds. In the actual rounds, the time limit will be <strong>#{TIME_NEXT_CLICK} seconds</strong> instead</li>
        </ol>

        <br><br>
        The score you receive on these practice rounds will <b>NOT</b> count towards your final score for this game.
        <br><br>
        </div>
        Click 'Next' to start with the practice rounds.
        """

    ]
  }
  # Practice Mouselab trials for each conditions
  task_control["practice_trials"] = {
    type: jsPsychMouselabMDP
    graph: STRUCTURE.graph
    layout: STRUCTURE.layout
    initial: STRUCTURE.initial
    num_trials: NUM_TUTORIAL_TRIALS
    forbidReclick: true
    revealOnArrive: false
    nextClickTimeLimit: PRACTICE_TIME_NEXT_CLICK
    stateResetMs: TIME_NODE_REVEAL * 1000
    clickDelay: 1000
    stateClickCost: () -> 0.5
    stateDisplay: 'click'
    accumulateReward: true
    wait_for_click: true
    highlightClicked: true
    withholdReward: false
    showCost: true
    scoreShift: 3.5
    stateBorder : () -> "rgb(187,187,187,1)"#getColor
    playerImage: 'static/images/spider.png'
    blockName: 'test'
    upperMessage: "Web of Cash - Practice Round"
    timeline: getPracticeTrials NUM_TUTORIAL_TRIALS
    trialCount: () -> pracTrialCount
    on_finish: () ->
      pracTrialCount += 1
      SCORE = 0
    on_timeline_start: () ->
      pracTrialCount = 0
  }
  task_misaligned["practice_trials"] = {
    type: jsPsychMouselabMDP
    graph: STRUCTURE.graph
    layout: STRUCTURE.layout
    initial: STRUCTURE.initial
    num_trials: NUM_TUTORIAL_TRIALS
    forbidReclick: true
    revealOnArrive: false
    nextClickTimeLimit: PRACTICE_TIME_NEXT_CLICK
    stateResetMs: TIME_NODE_REVEAL * 1000
    clickDelay: 1000,
    stateClickCost: () -> 0.5
    stateDisplay: 'click'
    accumulateReward: true
    wait_for_click: true
    highlightClicked: true
    withholdReward: false
    showCost: true
    scoreShift: 3.5
    stateBorder : () -> "rgb(187,187,187,1)"#getColor
    playerImage: 'static/images/spider.png'
    blockName: 'test'
    upperMessage: "Web of Cash - Practice Round"
    timeline: getPracticeTrials NUM_TUTORIAL_TRIALS
    trialCount: () -> pracTrialCount
    on_finish: () ->
      pracTrialCount += 1
      SCORE = 0
    on_timeline_start: () ->
      pracTrialCount = 0
  }
  # Second set of mouselab instructions for the disappearing timed condition
  task_control["mouselab_instructions_2"] = {
    type: jsPsychInstructions
    data:
      trial_id: "mouselab_instructions_2_control"
    show_clickable_nav: true
    pages: -> [

      """
        <h1> <em>Web of Cash</em> (3/3) - Actual Game </h1>
        Now that you understand how the node inspector works from the practice rounds, here is what you need to know about the actual rounds of the game that count:
        <br><br>
        <div style="text-align: left">

        <img class='display' style="width:50%; height:auto" src='static/images/web-of-cash-5-revealed.png'/>
        <div style="text-align: left">
        <li>You will be able to use the node inspector in each round.</li>
        <li>You will have #{TIME_NEXT_CLICK} seconds to make the next click after each subsequent click.</li>
        <li>You will have to click on the starting node before a round starts, after which the timer for your first click immediately begins.</li>
        <li><strong>You must spend <em>at least</em> #{PARAMS.MIN_TIME} seconds on each round.</strong> If you finish a round early, you'll have to wait until #{PARAMS.MIN_TIME} seconds have
            passed (before being able to move on).</li>
        <li>For each round of the game, the rewards on the web will be different. So, you have to make a new plan every time.</li>
        <li>At the end of each round, you will be told what your score for that round is.</li>
        <li>At the end of the game, you will be told what your score for the whole game is.</li>
        <li>The higher your score at the end of the game, the bigger your bonus will be!</li>
        </div>
      """
      """
        <h1> Quiz </h1>

        Before you can begin playing the <em>Web of Cash</em>, you <em>must</em> pass the instructions quiz to show
        that you understand the rules. If you get any of the questions
        incorrect, you will be brought back to the instructions to review and
        try the quiz again.

        You <em>must</em> pass the quiz in at most <strong>#{MAX_REPETITIONS}</strong> attempts to continue to the game. <strong>You have #{MAX_REPETITIONS-REPETITIONS} attempt(s) left.</strong>
        """
    ]
  }
  task_misaligned["mouselab_instructions_2"] = {
    type: jsPsychInstructions
    data:
      trial_id: "mouselab_instructions_2_misaligned"
    show_clickable_nav: true
    pages: -> [

      """
        <h1> <em>Web of Cash</em> (3/3) - Actual Game </h1>
        Now that you understand how the node inspector works from the practice rounds, here is what you need to know about the actual rounds of the game that count:
        <br><br>
        <div style="text-align: left">

        <img class='display' style="width:50%; height:auto" src='static/images/web-of-cash-5-revealed.png'/>
        <div style="text-align: left">
        <li>You will be able to use the node inspector in each round.</li>
        <li>You will have #{TIME_NEXT_CLICK} seconds to make the next click after each subsequent click.</li>
        <li>You will have to click on the starting node before a round starts, after which the timer for your first click immediately begins.</li>
        <li><strong>You must spend <em>at least</em> #{PARAMS.MIN_TIME} seconds on each round.</strong> If you finish a round early, you'll have to wait until #{PARAMS.MIN_TIME} seconds have
            passed (before being able to move on).</li>
        <li>For each round of the game, the rewards on the web will be different. So, you have to make a new plan every time.</li>
        <li>At the end of each round, you will be told what your score for that round is.</li>
        <li>At the end of the game, you will be told what your score for the whole game is.</li>
        <li>The higher your score at the end of the game, the bigger your bonus will be!</li>
        </div>
      """
      """
        <h1> Quiz </h1>

        Before you can begin playing the <em>Web of Cash</em>, you <em>must</em> pass the instructions quiz to show
        that you understand the rules. If you get any of the questions
        incorrect, you will be brought back to the instructions to review and
        try the quiz again.

        You <em>must</em> pass the quiz in at most <strong>#{MAX_REPETITIONS}</strong> attempts to continue to the game. <strong>You have #{MAX_REPETITIONS-REPETITIONS} attempt(s) left.</strong>
        """
    ]
  }


  # Mouselab instructions quiz for disappear condition
  task_control["mouselab_quiz"] = {
    preamble: ->  """
      <h1> Quiz </h1>

    """
    type: jsPsychSurveyMultiChoice
    questions: [
      {prompt: COST_QUESTION, options: COST_ANSWERS,  horizontal: false, required: true}
      {prompt: "Will you receive a bonus?", options: ['No.', 'I will receive a $1 bonus regardless of my performance.', 'I will receive a $1 bonus if I perform well, otherwise I will receive no bonus.', 'The better I perform the higher my bonus will be.'],  horizontal: false, required: true}
      {prompt: "Will each round be the same?", options: ['Yes.','No, the amount of cash at each node of the web may be different each time.', 'No, the structure of the web will be different each time.'],  horizontal: false, required: true}
      {prompt: "What is the objective of the game?", options: ["To get the highest total score.", "To finish the game in the shortest amount of time.", "To click on the least number of nodes."],  horizontal: false, required: true}
      {prompt: "When can you use the node inspector?", options: ['Only after moving the spider.','Any time during the round.', 'Only before moving the spider.'],  horizontal: false, required: true}
      {prompt: "How long do you have to make the next click when using the node inspector?", options: CLICK_TIME_ANSWERS,  horizontal: false, required: true}
    ]
    data: {
      correct: {
        Q0: COST_CORRECT
        Q1: 'The better I perform the higher my bonus will be.'
        Q2: 'No, the amount of cash at each node of the web may be different each time.'
        Q3: "To get the highest total score."
        Q4: 'Only before moving the spider.'
        Q5: CLICK_TIME_CORRECT
      }
      trial_id: "mouselab_quiz_control"
    }
  }
  task_misaligned["mouselab_quiz"] = {
    preamble: ->  """
      <h1> Quiz </h1>

    """
    type: jsPsychSurveyMultiChoice
    questions: [
      {prompt: COST_QUESTION, options: COST_ANSWERS,  horizontal: false, required: true}
      {prompt: "Will you receive a bonus?", options: ['No.', 'I will receive a $1 bonus regardless of my performance.', 'I will receive a $1 bonus if I perform well, otherwise I will receive no bonus.', 'The better I perform the higher my bonus will be.'],  horizontal: false, required: true}
      {prompt: "Will each round be the same?", options: ['Yes.','No, the amount of cash at each node of the web may be different each time.', 'No, the structure of the web will be different each time.'],  horizontal: false, required: true}
      {prompt: "What is the objective of the game?", options: ["To get the highest total score.", "To finish the game in the shortest amount of time.", "To click on the least number of nodes."],  horizontal: false, required: true}
      {prompt: "When can you use the node inspector?", options: ['Only after moving the spider.','Any time during the round.', 'Only before moving the spider.'],  horizontal: false, required: true}
      {prompt: "How long do you have to make the next click when using the node inspector?", options: CLICK_TIME_ANSWERS,  horizontal: false, required: true}
    ]
    data: {
      correct: {
        Q0: COST_CORRECT
        Q1: 'The better I perform the higher my bonus will be.'
        Q2: 'No, the amount of cash at each node of the web may be different each time.'
        Q3: "To get the highest total score."
        Q4: 'Only before moving the spider.'
        Q5: CLICK_TIME_CORRECT
      }
      trial_id: "mouselab_quiz_misaligned"
    }
  }

  fullscreen = {
    type: jsPsychFullscreen,
    fullscreen_mode: true,
    conditional_function: ->
      console.log(INSTRUCTIONS_FAILED)
      return INSTRUCTIONS_FAILED
  }

  # Looping mouselab instructions until quiz is passed
  task_control["mouselab_instruct_loop"] = {
    timeline: [
      fullscreen,
      task_control["mouselab_instructions_1"],
      task_control["practice_trials"],
      task_control["mouselab_instructions_2"],
      task_control["mouselab_quiz"]
    ]
    conditional_function: ->
      if DEBUG_INSTRUCTIONS
        return true
      else
        return false
    loop_function: (data) ->
      responses = data.last(1).values()[0].response
      for resp_id, response of responses
        if not (data.last(1).values()[0].correct[resp_id] == response)
          REPETITIONS += 1
          if REPETITIONS < MAX_REPETITIONS

            alert """You got at least one question wrong. We'll send you back to the instructions and then you can try again. Number of attempts left: #{MAX_REPETITIONS-REPETITIONS}."""
            INSTRUCTIONS_FAILED = true
            return true # try again
      psiturk.saveData()
      return false
  }
  task_misaligned["mouselab_instruct_loop"] = {
    timeline: [
      fullscreen,
      task_misaligned["mouselab_instructions_1"],
      task_misaligned["practice_trials"],
      task_misaligned["mouselab_instructions_2"],
      task_misaligned["mouselab_quiz"]
    ]
    conditional_function: ->
      if DEBUG_INSTRUCTIONS
        return true
      else
        return false
    loop_function: (data) ->
      responses = data.last(1).values()[0].response
      for resp_id, response of responses
        if not (data.last(1).values()[0].correct[resp_id] == response)
          REPETITIONS += 1
          if REPETITIONS < MAX_REPETITIONS

            alert """You got at least one question wrong. We'll send you back to the instructions and then you can try again. Number of attempts left: #{MAX_REPETITIONS-REPETITIONS}."""
            INSTRUCTIONS_FAILED = true
            return true # try again
      psiturk.saveData()
      return false
  }

  # Final mouselab quiz for conditions with disappearing node values
  self_report =
    preamble: -> """
      <h1>Self-Report on Performance</h1>

      Please answer the following questions about how you approached the <strong>Web of Cash</strong> game.

    """
    type: jsPsychSurveyText
    data:
      trial_id: "self_report_control"
    questions: [
      {prompt: "What was the strategy you used in the Web of Cash game? Briefly describe it in a couple of sentences.", required: true, rows: 10}
      {prompt: "Did you improve your strategy in the Web of Cash game over time? If so, how did you do it?", required: true, rows: 10}
      {prompt: "How difficult did you find it to improve your performance in the Web of Cash game? What made it difficult?", required: true, rows: 10}
    ]
  self_report_2 =
    preamble: -> """
      <h1>Self-Report on Performance</h1>

      <br>For the following questions, answer to which extent you agree with the presented statements about your click strategy during the Web of Cash game. Please answer the following questions <strong>only with respect to the nodes that you revealed by clicking.</strong><br>

    """
    type: jsPsychSurveyMultiChoice
    data:
      trial_id: "self_report_2"
    questions: [
      {prompt: "I clicked the nodes at the first level", options: ["Strongly disagree", "Disagree", "Neither disagree nor agree", "Agree", "Strongly agree"], required: true}
      {prompt: "I clicked the nodes at the first level only to receive the $0.25 reward", options: ["Strongly disagree", "Disagree", "Neither disagree nor agree", "Agree", "Strongly agree"], required: true}
      {prompt: "I did not click any nodes just for the reward.", options: ["Strongly disagree", "Disagree", "Neither disagree nor agree", "Agree", "Strongly agree"], required: true}
      {prompt: "I considered all the revealed node values, including those at the first level, in choosing my path.", options: ["Strongly disagree", "Disagree", "Neither disagree nor agree", "Agree", "Strongly agree"], required: true}
      {prompt: "I did not consider the values of the nodes at the first level, even though I clicked on them.", options: ["Strongly disagree", "Disagree", "Neither disagree nor agree", "Agree", "Strongly agree"], required: true}
    ]

  self_reports = [self_report, self_report_2]
  task_control["final_quiz"] =
    on_start: ->
      SCORE = Math.round(SCORE * 100) / 100
    preamble: -> """
      <h1>Quiz</h1>

      Congratulations for making it to the end of the <em>Web of Cash</em> game!

      Your total score for the game was <strong>$#{SCORE}</strong>. The bonus that you receive will be based on this.
      <br><br>

      Please answer the following questions about the task before moving on to the questionnaires.

    """
    type: jsPsychSurveyMultiChoice
    data:
      trial_id: "final_quiz_control"
    on_finish: ->
      BONUS = calculateBonus().toFixed(2)
    questions: [
      {prompt: "What is the range of node values in the first step (closest to the start, in the center)?", options: ['$-16 to 16', '$-2 to $2', '$-88 to $88'], required: true}
      {prompt: "What is the range of node values in the fourth step?", options: ['$-4 to $4', '$-16 to $16', '$-32 to $32'], required: true}
      {prompt: "What is the range of node values in the last step (furthest from the start, the edges)?", options: ['$-32 to $32', '$-16 to $16', '$-88 to $88'], required: true}
      {prompt: COST_QUESTION_BASELINE, options: COST_ANSWERS_BASELINE, required: true}
      {prompt: "How motivated were you to perform the task?", options: ["Very unmotivated", "Slightly unmotivated", "Neither motivated nor unmotivated", "Slightly motivated", "Very motivated"], required: true}
    ]
  task_misaligned["final_quiz"] =
    on_start: ->
      SCORE = Math.round(SCORE * 100) / 100
    preamble: -> """
      <h1>Quiz</h1>

      Congratulations for making it to the end of the <em>Web of Cash</em> game!

      Your total score for the game was <strong>$#{SCORE}</strong>. The bonus that you receive will be based on this.
      <br><br>

      Please answer the following questions about the task before moving on to the questionnaires.

    """
    type: jsPsychSurveyMultiChoice
    data:
      trial_id: "final_quiz_control"
    on_finish: ->
      BONUS = calculateBonus().toFixed(2)
    questions: [
      {prompt: "What is the range of node values in the first step (closest to the start, in the center)?", options: ['$-16 to 16', '$-2 to $2', '$-88 to $88'], required: true}
      {prompt: "What is the range of node values in the fourth step?", options: ['$-4 to $4', '$-16 to $16', '$-32 to $32'], required: true}
      {prompt: "What is the range of node values in the last step (furthest from the start, the edges)?", options: ['$-32 to $32', '$-16 to $16', '$-88 to $88'], required: true}
      {prompt: COST_QUESTION_BASELINE, options: COST_ANSWERS_BASELINE, required: true}
      {prompt: "How motivated were you to perform the task?", options: ["Very unmotivated", "Slightly unmotivated", "Neither motivated nor unmotivated", "Slightly motivated", "Very motivated"], required: true}
    ]

  minimumTime = PARAMS.MIN_TIME
  if DEBUG
    minimumTime = null

  ready_screen =
    type: jsPsychHtmlKeyboardResponse
    data:
      trial_id: "mdp_ready"
    choices: [" "]
    stimulus: """

          <h1> Get ready to start the game! </h1>

          Thank you for reading the instructions. Get ready start with the #{NUM_TRIALS} rounds of this game.
          <br><br>
          If you need to take a break, feel free to take one after the end of a round, before continuing to the next one.
          <br><br>
          Remember, the more money the spider gets, the bigger your bonus will be!
          <br><br>
          <div style='text-align: center;'>Press <code>space</code> to begin.</div>

          <br><br>
          (If, at any point, the <code>space</code> key does not take you to the next page, click once on the text and try again.)
        """
  mdp_trials = getTrials NUM_TRIALS

  task_control["test_trials"] = {
    type: jsPsychMouselabMDP
    graph: STRUCTURE.graph
    layout: STRUCTURE.layout
    initial: STRUCTURE.initial
    num_trials: NUM_TRIALS
    stateClickCost: (s) -> CLICK_COST_FNS["control"](CLICK_DEPTHS[parseInt(s)])
    stateDisplay: 'click'
    accumulateReward: true
    wait_for_click: true
    forbidReclick: true
    revealOnArrive: false
    highlightClicked: true
    showCost: true
    clickDelayFunction: (s) -> CLICK_DELAY_FNS["control"](CLICK_DEPTHS[parseInt(s)])
    nextClickTimeLimit: TIME_NEXT_CLICK
    stateResetMs: TIME_NODE_REVEAL * 1000
    minTime: minimumTime
    stateBorder : () -> "rgb(187,187,187,1)"#getColor
    playerImage: 'static/images/spider.png'
    blockName: 'test'
    timeline: mdp_trials
    trialCount: () -> trialCount
    on_finish: () ->
      trialCount += 1
    on_timeline_finish: () ->
      trialCount = 0
  }
  task_misaligned["test_trials"] = {
    type: jsPsychMouselabMDP
    graph: STRUCTURE.graph
    layout: STRUCTURE.layout
    initial: STRUCTURE.initial
    num_trials: NUM_TRIALS
    stateClickCost: (s) -> CLICK_COST_FNS["misaligned"](CLICK_DEPTHS[parseInt(s)])
    stateDisplay: 'click'
    accumulateReward: true
    wait_for_click: true
    forbidReclick: true
    revealOnArrive: false
    highlightClicked: true
    showCost: true
    clickDelayFunction: (s) -> CLICK_DELAY_FNS["misaligned"](CLICK_DEPTHS[parseInt(s)])
    nextClickTimeLimit: TIME_NEXT_CLICK
    stateResetMs: TIME_NODE_REVEAL * 1000
    minTime: minimumTime
    stateBorder : () -> "rgb(187,187,187,1)"#getColor
    playerImage: 'static/images/spider.png'
    blockName: 'test'
    timeline: mdp_trials
    trialCount: () -> trialCount
    on_finish: () ->
      trialCount += 1
    on_timeline_finish: () ->
      trialCount = 0
  }

  #final screen if participants didn't pass instructions quiz (control condition)
  finish_fail = {
       type: jsPsychSurveyText
       data:
        trial_id: "finish_fail"
       preamble: ->  """
           <h1> You've completed the HIT </h1>

           Thanks for participating. Unfortunately we can only allow those who understand the instructions to continue with the HIT.

           You will receive only the base pay amount when you submit.

           Before you submit the HIT, we are interested in knowing some demographic info, and if possible, what problems you encountered with the instructions/HIT.
         """

       questions: [
         {prompt:'Was anything confusing or hard to understand?',required:false,rows:10}
         {prompt:'What is your age?',required:true}
         {prompt:'What is your gender?',required:true}
         {prompt:'Are you colorblind?',required:true, rows:2}
         {prompt:'Additional comments?',required:false,rows:10}
       ]
       button_label: 'Continue'
     }

  #final screen, if participants actually participated, regardless of condition
  finish = {
    type: jsPsychSurveyText
    preamble: ->  """
        <h1> You've completed the HIT </h1>

        Thanks for participating. We hope you had fun! Based on your
        performance in all the games, you will be awarded a bonus to your account within the next few days.

        Please briefly answer the questions below before you submit the HIT.
      """

    questions: [
      {prompt: 'Was anything confusing or hard to understand?', required: false, rows:10}
      {prompt: "After completing this HIT, did you realize that you had already participated in a Web of Cash HIT before? Don't worry, we won't penalize you based on your response here. We completely understand that it's hard to remember which HITs you have or haven't completed.", required: true, rows:5}
      {prompt: 'Additional comments?', required: false, rows:10}
    ]
    button_label: 'Continue'
  }

  #demographics, regardless of condition
  demographics = {
    type: jsPsychSurveyHtmlForm
    preamble: "<h1>Demographics</h1> <br> Please answer the following questions.",
    html: """
      <p>
        What is your gender?<br>
        <input required type="radio" name="gender" value="male"> Male<br>
        <input required type="radio" name="gender" value="female"> Female<br>
        <input required type="radio" name="gender" value="other"> Other<br>
      </p>
      <br>
      <p>
        How old are you?<br>
        <input required type="number" name="age">
      </p>
      <br>
      <p>
        Are you colorblind?<br>
        <input required type="radio" name="colorblind" value="0">No<br>
        <input required type="radio" name="colorblind" value="1">Yes<br>
        <input required type="radio" name="colorblind" value="2">Don't know<br>
      </p>
      <br>
      <p>
        Since we are doing science, we would now like to know how much attention/effort you put into the game and any surveys. <br><em>(Please note that, even if you answer \'No effort\', it will not affect your pay in anyway and we will not exclude you from future studies based on this response. It will just enable us to do our data analysis better. <strong> We value your time! </strong>)</em><br>
        <input required type="radio" name="effort" value="0">A lot of effort (e.g. paying full attention throughout, trying to get a high score in the <em> Web of Cash </em>)<br>
        <input required type="radio" name="effort" value="1">Some effort (e.g. mostly paying attention, listening to music or a podcast)<br>
        <input required type="radio" name="effort" value="2">Minimal effort (e.g. watching TV and not always looking at the screen, just trying to get through the <em> Web of Cash </em> trials)<br>
        <input required type="radio" name="effort" value="3">No effort (e.g. randomly clicking)<br>
        <input required type="radio" name="effort" value="4">Unsure<br>
      </p>
    """
  }
  # ================================================ #
  # ========= TIMELINE LOGIC ======================= #
  # ================================================ #

  #if the subject fails the quiz 4 times they are just thanked and must leave
  if_node1 =
    timeline: [finish_fail]
    conditional_function: ->
        if REPETITIONS > MAX_REPETITIONS
            return true
        else
            return false
  # if the subject passes the quiz, they continue and can earn a bonus for their performance
  # MDP trials and end if quiz is passed
  task_control["if_node2"] =
    timeline: [ready_screen, task_control["test_trials"], task_control["final_quiz"], self_reports..., demographics, finish]
    conditional_function: ->
      if REPETITIONS > MAX_REPETITIONS
        return false
      else
        return true
  task_misaligned["if_node2"] =
    timeline: [ready_screen, task_misaligned["test_trials"], task_misaligned["final_quiz"], self_reports..., demographics, finish]
    conditional_function: ->
      if REPETITIONS > MAX_REPETITIONS
        return false
      else
        return true


  experiment_timeline = undefined
  # No scarcity and distractor trials present (control condition)
  if CONDITION == 0
    experiment_timeline = [
      task_control["experiment_instructions"],
      task_control["mouselab_instruct_loop"]
      if_node1,
      task_control["if_node2"]
    ]
  else if CONDITION == 1
    experiment_timeline = [
      task_misaligned["experiment_instructions"],
      task_misaligned["mouselab_instruct_loop"]
      if_node1,
      task_misaligned["if_node2"]
    ]
  # ================================================ #
  # ========= START AND END THE EXPERIMENT ========= #
  # ================================================ #

  # experiment goes to full screen at start
  experiment_timeline.unshift({type:jsPsychFullscreen, message: '<p>The experiment will switch to full screen mode when you press the button below.<br> Please do not leave full screen for the duration of the experiment. </p>', button_label:'Continue', fullscreen_mode:true, delay_after:1000})
  # at end, show the secret code and then leave fullscreen
  secret_code_trial =
    type: jsPsychHtmlButtonResponse
    choices: ['Finish HIT']
    stimulus: () -> """
    Press 'Finish HIT' in order to reach the completion code. Once the data has been saved, you will receive the code either in this window or in the original browser window where you started the experiment.

  """
  experiment_timeline.push(secret_code_trial)
  experiment_timeline.push({type:jsPsychFullscreen, fullscreen_mode:false, delay_after:1000})
  # bonus is the (roughly) total score multiplied by something, bounded by min and max amount
  calculateBonus = ->
    bonus = SCORE * PARAMS.bonusRate
    bonus = (Math.round (bonus * 100)) / 100  # round to nearest cent
    return Math.min(Math.max(0, bonus),MAX_AMOUNT)

  #saving, finishing functions
  # These functions are defined once again init jsPsych - not used here
  reprompt = null
  save_data = ->
    psiturk.saveData
      success: ->
        console.log 'Data saved to psiturk server.'
        if reprompt?
          window.clearInterval reprompt
        await completeExperiment uniqueId # Encountering an error here? Try to use Coffeescript 2.0 to compile.
        psiturk.completeHIT();
      error: -> prompt_resubmit

  prompt_resubmit = ->
    $('#jspsych-target').html """
      <h1>Oops!</h1>
      <p>
      Something went wrong submitting your HIT.
      This might happen if you lose your internet connection.
      Press the button to resubmit.
      </p>
      <button id="resubmit">Resubmit</button>
    """
    $('#resubmit').click ->
      $('#jspsych-target').html 'Trying to resubmit...'
      reprompt = window.setTimeout(prompt_resubmit, 10000)
      save_data()
  # initialize jspsych experiment -- without this nothing happens
  jsPsych.run(experiment_timeline)