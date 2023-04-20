const textArea = document.getElementById('text');
const characterCount = document.getElementById('character-count');

textArea.addEventListener('input', function() {
  const charCount = textArea.value.length;

  if (charCount === 4096) {
    characterCount.classList.add('red');
  } else {
    characterCount.classList.remove('red');
  }

  characterCount.textContent = charCount === 1 ? '1 character' : `${charCount} characters`;
});
