import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="speech-to-text"
export default class extends Controller {
  static targets = ["microphoneButton", "chatInput"]

  connect() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (SpeechRecognition) {
      this.microphoneButtonTarget.classList.remove("hidden")
    } else {
      return
    }

    this.recognition = new SpeechRecognition();
    this.recognition.continuous = false;
    this.recognition.lang = 'en-US';
    this.recognition.interimResults = false;
    this.recognition.maxAlternatives = 1;

    this.recognition.onresult = this.handleResult.bind(this);
    this.recognition.onerror = this.handleError.bind(this);
    this.recognition.onstart = this.handleStart.bind(this);
    this.recognition.onend = this.handleEnd.bind(this);

    this.isRecognizing = false; // Track if recognition is active
  }

  startRecognition(event) {
    event.preventDefault();
    if (this.isRecognizing) {
      console.log("Recognition already started");
      return;
    }

    try {
      this.recognition.start();
      this.isRecognizing = true;
    } catch (error) {
      console.error("Recognition start failed:", error);
      this.isRecognizing = false;
    }
  }

  handleStart() {
    this.microphoneButtonTarget.classList.add("recording");
  }

  handleEnd() {
    this.microphoneButtonTarget.classList.remove("recording");
    this.isRecognizing = false;
  }

  handleResult(event) {
    const transcript = event.results[0][0].transcript;
    this.chatInputTarget.value += ` ${transcript}`;
    this.recognition.stop();
  }

  handleError(event) {
    console.error(`Error occurred in recognition: ${event.error}`);
    this.isRecognizing = false;
    alert(`Speech recognition error: ${event.error}`);
  }
}
