const copyLink = () => {
  const buttons = document.querySelectorAll('.btn-copier');
  buttons.forEach((button) => {
    button.addEventListener('click', () => {
      const link_id = button.dataset.pageid;
      const link = document.querySelector(`.url-de-la-page-${link_id}`);
      navigator.clipboard.writeText(link.innerText);
      button.innerHTML = `<i class="fa-solid fa-check"></i>`;
      button.classList.add('copied');
      setInterval(() => {
        button.innerHTML = `<i class="fa-solid fa-clone" title="copier"></i>`;
        button.classList.remove('copied');
      }, 700);

    });
  });
}

export { copyLink };
