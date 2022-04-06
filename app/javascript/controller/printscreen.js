const printScreen = () => {
  const button = document.getElementById('print-screen');
 if (button) {
   button.addEventListener('click', () => {
    window.print();
   });
 }
}

export { printScreen };
