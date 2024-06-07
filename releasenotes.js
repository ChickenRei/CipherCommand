// Sample data for release notes
const releases = [
  {
      version: "v1.0",
      date: "May 27, 2024",
      notes: "Initial release"
  },
  {
      version: "v1.1",
      date: "May 31, 2024",
      notes: "Bug fixes and performance improvements"
  },
];

// Function to generate release notes HTML
function generateReleaseNotes() {
  const releaseNotesContainer = document.getElementById("release-notes");
  releases.forEach(release => {
      const releaseDiv = document.createElement("div");
      releaseDiv.classList.add("release");
      releaseDiv.innerHTML = `
          <h2>${release.version}</h2>
          <p><strong>Date:</strong> ${release.date}</p>
          <p><strong>Notes:</strong> ${release.notes}</p>
      `;
      releaseNotesContainer.appendChild(releaseDiv);
  });
}

// Call the function to generate release notes when the page loads
window.onload = generateReleaseNotes;
