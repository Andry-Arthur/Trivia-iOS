//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//  Modified by Andry Arthur on 3/26/25.
//

import UIKit

class TriviaViewController: UIViewController {

    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var questionContainerView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var answerButton0: UIButton!
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!

    private var questions = [TriviaQuestion]()

    private var currQuestionIndex = 0
    private var numCorrectQuestions = 0
    private var answerButtons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        answerButtons = [answerButton0, answerButton1, answerButton2, answerButton3]
        addGradient()
        questionContainerView.layer.cornerRadius = 8.0
        // TODO: FETCH TRIVIA QUESTIONS HERE
        TriviaQuestionService.fetchTriviaQuestions { [weak self] fetchedQuestions in
            DispatchQueue.main.async {
                if let fetchedQuestions = fetchedQuestions {
                    self?.questions = fetchedQuestions
                    self?.updateQuestion(withQuestionIndex: 0)  // Start with the first question
                } else {
                    print("Failed to fetch trivia questions.")
                }
            }
        }
    }

    private func updateQuestion(withQuestionIndex questionIndex: Int) {
        resetAnswerButtonStyles()
        enableAnswerButtons()
        currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
        let question = questions[questionIndex]
        questionLabel.text = decodeHtmlEntities(in: question.question)
        categoryLabel.text = decodeHtmlEntities(in: question.category)

        if question.incorrectAnswers.count == 1 {
            // This is likely a True/False question
            answerButton0.setTitle(decodeHtmlEntities(in: "True"), for: .normal)
            answerButton1.setTitle(decodeHtmlEntities(in: "False"), for: .normal)
            answerButton2.isHidden = true
            answerButton3.isHidden = true
        } else {
            // Multiple choice question
            var answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
            if answers.count > 0 {
                answerButton0.setTitle(decodeHtmlEntities(in: answers[0]), for: .normal)
            }
            if answers.count > 1 {
                answerButton1.setTitle(decodeHtmlEntities(in: answers[1]), for: .normal)
                answerButton1.isHidden = false
            }
            if answers.count > 2 {
                answerButton2.setTitle(decodeHtmlEntities(in: answers[2]), for: .normal)
                answerButton2.isHidden = false
            }
            if answers.count > 3 {
                answerButton3.setTitle(decodeHtmlEntities(in: answers[3]), for: .normal)
                answerButton3.isHidden = false
            }
        }
    }

    private func updateToNextQuestion() {
        currQuestionIndex += 1
        guard currQuestionIndex < questions.count else {
            showFinalScore()
            return
        }
        updateQuestion(withQuestionIndex: currQuestionIndex)
    }

    private func isCorrectAnswer(_ answer: String) -> Bool {
        let currentQuestion = questions[currQuestionIndex]
        let decodedAnswer = decodeHtmlEntities(in: answer)
        if currentQuestion.incorrectAnswers.count == 1 {
            // True/False question
            return decodedAnswer.lowercased() == decodeHtmlEntities(in: currentQuestion.correctAnswer).lowercased()
        } else {
            // Multiple choice question
            return decodedAnswer == decodeHtmlEntities(in: currentQuestion.correctAnswer)
        }
    }

    private func showFinalScore() {
        let alertController = UIAlertController(title: "Game over!",
                                                message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                                preferredStyle: .alert)
        let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
            restartGame()
        }
        alertController.addAction(resetAction)
        present(alertController, animated: true, completion: nil)
    }

    private func restartGame() {
        // Reset question index and score
        currQuestionIndex = 0
        numCorrectQuestions = 0

        // Refetch trivia questions from the API
        TriviaQuestionService.fetchTriviaQuestions { [weak self] fetchedQuestions in
            DispatchQueue.main.async {
                if let fetchedQuestions = fetchedQuestions {
                    self?.questions = fetchedQuestions
                    self?.updateQuestion(withQuestionIndex: 0)  // Start from the first question
                } else {
                    print("Failed to fetch new trivia questions.")
                }
            }
        }
    }

    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                                UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func disableAnswerButtons() {
        answerButtons.forEach { $0.isEnabled = false }
    }

    private func enableAnswerButtons() {
        answerButtons.forEach { $0.isEnabled = true }
    }

    private func resetAnswerButtonStyles() {
        answerButtons.forEach {
            $0.backgroundColor = nil // Reset background color
            $0.setTitleColor(UIColor.label, for: .normal) // Reset text color to default
        }
    }

    @IBAction func didTapAnswerButton0(_ sender: UIButton) {
        handleAnswerSelection(sender)
    }

    @IBAction func didTapAnswerButton1(_ sender: UIButton) {
        handleAnswerSelection(sender)
    }

    @IBAction func didTapAnswerButton2(_ sender: UIButton) {
        handleAnswerSelection(sender)
    }

    @IBAction func didTapAnswerButton3(_ sender: UIButton) {
        handleAnswerSelection(sender)
    }

    private func handleAnswerSelection(_ sender: UIButton) {
        guard let selectedAnswer = sender.titleLabel?.text else { return }
        let isCorrect = isCorrectAnswer(selectedAnswer)

        // Provide visual feedback with slightly better colors
        if isCorrect {
            sender.backgroundColor = UIColor(red: 0.76, green: 0.93, blue: 0.56, alpha: 1.0) // Light green
            sender.setTitleColor(.black, for: .normal) // Ensure text is readable
            numCorrectQuestions += 1
        } else {
            sender.backgroundColor = UIColor(red: 0.95, green: 0.63, blue: 0.58, alpha: 1.0) // Light red
            sender.setTitleColor(.black, for: .normal) // Ensure text is readable
            // Optionally highlight the correct answer with a more distinct color
            if let correctAnswerIndex = answerButtons.firstIndex(where: { decodeHtmlEntities(in: $0.titleLabel?.text ?? "") == decodeHtmlEntities(in: questions[currQuestionIndex].correctAnswer) }) {
                answerButtons[correctAnswerIndex].backgroundColor = UIColor(red: 0.61, green: 0.85, blue: 0.41, alpha: 1.0) // Slightly darker green for correct answer
                answerButtons[correctAnswerIndex].setTitleColor(.black, for: .normal)
            }
        }

        // Disable all answer buttons
        disableAnswerButtons()

        // Move to the next question after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.updateToNextQuestion()
        }
    }

    // MARK: - Helper Function

    private func decodeHtmlEntities(in string: String) -> String {
        guard let data = string.data(using: .utf8) else {
            return string
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        } else {
            return string
        }
    }
}
