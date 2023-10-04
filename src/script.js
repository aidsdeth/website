function copyEmail() {
    navigator.clipboard.writeText
      ("aidsdeth@gmail.com")
}

function copyPhoneNum() {
    navigator.clipboard.writeText
      ("(910)-284-2510")
}

function goNCSUcerts () {
    return window.open("https://api.badgr.io/public/collections/fa772cfc22ea459b91b81a94171ed99d", "_blank")
}

function goGithub () {
    return window.open("https://github.com/aidsdeth", "_blank")
}
  
function goLinkedin () {
    return window.open("https://www.linkedin.com/in/aidandeth/", "_blank")
}

document.getElementById('menuToggle').addEventListener('click', function() {
    var nav = document.querySelector('nav');
    if (nav.style.right === '0px') {
        nav.style.right = '-300px';  // hide
    } else {
        nav.style.right = '0px';     // show
    }
});