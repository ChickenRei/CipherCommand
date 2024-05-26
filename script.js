const texts = [
  "Cipher Command",
  "Welcome to the Cipher Command Download Page.",
  "Choose an option below to download Cipher Command:",
  "Version: 1.0",
  "Developer: Daniel Reiman",
  "Copyright (C) 2024 Daniel Reiman. All rights reserved."
];

let index = 0;
let textIndex = 0;
let currentText = "";
const currentElements = document.querySelectorAll(".typing-animation");
const keypressSound = document.getElementById("keypress-sound");

keypressSound.volume = 0.5;

function type() {
  if (index < texts.length) {
    keypressSound.play();
    currentText = texts[index];
    currentElements[index].textContent = currentText.substring(0, textIndex + 1);

    currentElements.forEach((el, i) => {
      if (i === index) {
        el.classList.add("show-caret");
      } else {
        el.classList.remove("show-caret");
      }
    });

    textIndex++;
    if (textIndex < currentText.length) {
      setTimeout(type, 80);
    } else {
      index++;
      textIndex = 0;
      if (index === 3) {
        document.querySelector(".buttons").style.display = "block";
      }
      if (index < texts.length) {
        setTimeout(type, 500);
      } else {
        keypressSound.pause();
        currentElements[currentElements.length - 1].classList.remove("show-caret");
      }
    }
  }
}

function startDownload(fileUrl) {
  document.querySelector(".buttons").style.display = "none";

  const progressBar = document.createElement("div");
  progressBar.className = "progress-container";
  const progress = document.createElement("div");
  progress.className = "progress-bar";
  progressBar.appendChild(progress);
  document.querySelector(".content").appendChild(progressBar);
  progressBar.style.display = "block";

  let percent = 0;
  const interval = setInterval(() => {
    percent += 10;
    progress.style.width = percent + "%";
    progress.textContent = percent + "%";
    if (percent >= 100) {
      clearInterval(interval);
      progressBar.style.display = "none";
      document.querySelector(".buttons").style.display = "block";
      window.open(fileUrl);
    }
  }, 500);
}

document.addEventListener("DOMContentLoaded", () => {
  type();
});
