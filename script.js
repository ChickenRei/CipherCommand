
const texts = [
  "Cipher Command",
  "Welcome to the Cipher Command Download Page.",
  "Choose an option below to download Cipher Command:",
  "Version: 1.0.0",
  "Developer: Daniel Reiman",
  "Copyright (C) 2024 Daniel Reiman. All rights reserved."
];

let index = 0;
let textIndex = 0;
let currentText = "";
let currentElement = document.querySelectorAll(".typing-animation");

const keypressSound = document.getElementById("keypress-sound");
keypressSound.volume = 0.5
function type() {
  if (index < texts.length) {
    keypressSound.play()
    currentText = texts[index];
    currentElement[index].textContent = currentText.substring(0, textIndex + 1); // Append the complete sentence
    keypressSound.play();

    currentElement.forEach((el, i) => {
      if (i === index) {
        el.classList.add("show-caret");
      } else {
        el.classList.remove("show-caret");
      }
    });
    textIndex++;
    if (textIndex < currentText.length) {
      setTimeout(type, 100); // Adjust the typing speed as needed
    } else {
      index++;
      textIndex = 0;
      if (index === 3) {
        document.querySelector(".buttons").style.display = "block"; // Show buttons after typing "Choose an option below..."
      }
      if (index < texts.length) {
        setTimeout(type, 295); // Delay before typing the next text
      } else {
        keypressSound.pause(); 
        currentElement[currentElement.length - 1].classList.remove("show-caret");

      }
    }
  }
}

function startDownload(fileUr) {
  // Hide buttons
  document.querySelector(".buttons").style.display = "none";
  // Show progress bar
  const progressBar = document.createElement("div");
  progressBar.className = "progress-container";
  const progress = document.createElement("div");
  progress.className = "progress-bar";
  progressBar.appendChild(progress);
  document.querySelector(".content").appendChild(progressBar);

  let percent = 0;
  const interval = setInterval(function() {
      percent += 10;
      progress.style.width = percent + "%";
      progress.textContent = percent + "%";
      if (percent >= 100) {
          clearInterval(interval);
          // Hide progress bar
          progressBar.style.display = "none";
          // Show buttons again
          document.querySelector(".buttons").style.display = "block";

          window.open(fileUr)
        }
  }, 500);
}
// Trigger typing animation on page load
document.addEventListener("DOMContentLoaded", function() {
  type();
});