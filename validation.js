const companyRegExp = /^[A-Z0-9][a-zA-Z0-9- ]+$/;
const firstNameRegExp = /^[A-Z][a-zA-Z- ]+$/;
const lastNameRegExp = /^[A-Z][a-zA-Z- ]+$/
const emailRegExp = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(\.com)$/;
const phoneRegExp = /^[1-8][0-9]{10}$/;

function formValidation(){
  const companyDecision = validation(companyRegExp, 'company');
  const firstNameDecision = validation(firstNameRegExp, 'first_name');
  const lastNameDecision = validation(lastNameRegExp, 'last_name');
  const emailDecision = validation(emailRegExp, 'email');
  const phoneDecision = validation(phoneRegExp, 'phone');
  const reCaptchaDecision = reCaptchaValidation();
  return reCaptchaDecision && companyDecision && firstNameDecision && lastNameDecision && emailDecision && phoneDecision;
}

function validation(regexp, field){
  const element = document.getElementById(field);
  if(!regexp.test(element.value)){
    element.style.borderTop = 'none';
    element.style.borderLeft = 'none';
    element.style.borderRight = 'none';
    element.style.borderBottom = 'solid 2px red';
  }
  else{
    element.style.borderTop = 'none';
    element.style.borderLeft = 'none';
    element.style.borderRight = 'none';
    element.style.borderBottom = 'solid 2px green';
  }
  return regexp.test(element.value);
}

function reCaptchaValidation(){
  recaptcha = document.getElementById('g-recaptcha-response');
  if(recaptcha.value != ''){
    return true;
  }
  else{
    alert('Please fill in the reCaptcha');
    return false;
  }
}