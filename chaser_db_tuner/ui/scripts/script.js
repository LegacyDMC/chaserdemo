let gtagratiotable9 = [-3.333, 3.333, 1.849, 1.253, 0.935, 0.767, 0.692, 0.686, 0.749, 0.9];
let gtagratiotable8 = [-3.333, 3.333, 1.898, 1.321, 1.011, 0.851, 0.788, 0.803, 0.9];
let gtagratiotable7 = [-3.333, 3.333, 1.934, 1.372, 1.070, 0.918, 0.867, 0.9];
let gtagratiotable6 = [-3.333, 3.333, 1.949, 1.392, 1.095, 0.946, 0.9];
let gtagratiotable5 = [-3.333, 3.333, 1.924, 1.358, 1.054, 0.9];
let gtagratiotable4 = [-3.333, 3.333, 1.826, 1.222, 0.9];
let gtagratiotable3 = [-3.333, 3.333, 1.567, 0.9];
let gtagratiotable2 = [-3.333, 3.333, 0.9];
let gtagratiotable1 = [-3.333, 0.9];
let gtagratiotable0 = [-3.333];

let gears
let speed

window.addEventListener('DOMContentLoaded', (event) => {
  const numberInputs = document.querySelectorAll('input[type=number]');
  numberInputs.forEach(input => {
      input.setAttribute('step', 'any');
  });
});

window.addEventListener('message', function(event) {
  var data = event.data;
  if (data.action === 'open') {
      gears = data.gears
      speed = data.topspeed
      document.getElementById('vehicleConfigContainer').style.display = 'block';
      document.getElementById('hasflywheel').value = data.flywheel;
      document.getElementById('flywheelweight').value = data.flywheelweight;
      document.getElementById('hasdifferential').value = data.diff;
      document.getElementById('frontdifflockprct').value = data.diffflock;
      document.getElementById('reardifflockprct').value = data.diffrlock;
      document.getElementById('tcsstate').value = data.tcsstate;
      document.getElementById('escstate').value = data.ecsstate;
      document.getElementById('atglockstate').value = data.glockstate;
      document.getElementById('tyretype').value = data.tyre;
      document.getElementById('transmissiontype').value = data.transmissiontype;
      document.getElementById('finaldrive').value = data.finaldrive;
      document.getElementById('atshiftpoint').value = data.atshiftpoint;
      document.getElementById('gear1').value = data.gearatios[1] || 0.5;
      document.getElementById('gear2').value = data.gearatios[2] || 0.5;
      document.getElementById('gear3').value = data.gearatios[3] || 0.5;
      document.getElementById('gear4').value = data.gearatios[4] || 0.5;
      document.getElementById('gear5').value = data.gearatios[5] || 0.5;
      document.getElementById('gear6').value = data.gearatios[6] || 0.5;
      document.getElementById('gear7').value = data.gearatios[7] || 0.5;
      document.getElementById('gear8').value = data.gearatios[8] || 0.5;
      document.getElementById('gear9').value = data.gearatios[9] || 0.5;
      document.getElementById('gear0').value = data.gearatios[0] || -0.5;
      document.getElementById('labelg1').textContent  = "1st "+"("+calculateTopSpeed(gears,data.finaldrive,data.gearatios[1],1,speed)+" KM/H)";
      document.getElementById('labelg2').textContent  = "2nd "+"("+calculateTopSpeed(gears,data.finaldrive,data.gearatios[2],2,speed)+" KM/H)";
      document.getElementById('labelg3').textContent  = "3rd "+"("+calculateTopSpeed(gears,data.finaldrive,data.gearatios[3],3,speed)+" KM/H)";
      document.getElementById('labelg4').textContent  = "4th "+"("+calculateTopSpeed(gears,data.finaldrive,data.gearatios[4],4,speed)+" KM/H)";
      document.getElementById('labelg5').textContent  = "5th "+"("+calculateTopSpeed(gears,data.finaldrive,data.gearatios[5],5,speed)+" KM/H)";
      document.getElementById('labelg6').textContent  = "6th "+"("+calculateTopSpeed(gears,data.finaldrive,data.gearatios[6],6,speed)+" KM/H)";
      document.getElementById('labelg7').textContent  = "7th "+"("+calculateTopSpeed(gears,data.finaldrive,data.gearatios[7],7,speed)+" KM/H)";
      document.getElementById('labelg8').textContent  = "8th "+"("+calculateTopSpeed(gears,data.finaldrive,data.gearatios[8],8,speed)+" KM/H)";
      document.getElementById('labelg9').textContent  = "9th "+"("+calculateTopSpeed(gears,data.finaldrive,data.gearatios[9],9,speed)+" KM/H)";
      document.getElementById('labelg0').textContent  = "R "+"("+calculateTopSpeed(gears,data.finaldrive,data.gearatios[0],0,speed)+" KM/H)";
      document.getElementById('turbotype').value = data.boosttype;
      document.getElementById('compressorsize').value = data.compressorsize;
      document.getElementById('peakturbodecayboost').value = data.peakturbodecayboost;
      document.getElementById('turbodecaypoint').value = data.turbodecaypoint;
      document.getElementById('maxtrboostpmax').value = data.maxtrboostpmax;
      document.getElementById('maxtrboostpmin').value = data.maxtrboostpmin;
      document.getElementById('maxtrboostpminprct').value = data.maxtrboostpminprct;
      document.getElementById('maxtrboostpmaxprct').value = data.maxtrboostpmaxprct;
      document.getElementById('booststartpoint').value = data.booststartpoint;
  }
});

function closeForm() {
  document.getElementById('vehicleConfigContainer').style.display = 'none';
  fetch(`https://${GetParentResourceName()}/closeVehicleConfigForm`, {
      method: 'POST',
      headers: {
          'Content-Type': 'application/json'
      },
      body: JSON.stringify({ action: 'close' })
  }).then(() => window.close()).catch(err => console.error('Error closing form:', err));
}

function calculateTopSpeed(gtagratiotableIndex, finaldrive, gearratiotable,gearcalc, topspeed) {
  var gtagratiotables = {
    1: gtagratiotable1,
    2: gtagratiotable2,
    3: gtagratiotable3,
    4: gtagratiotable4,
    5: gtagratiotable5,
    6: gtagratiotable6,
    7: gtagratiotable7,
    8: gtagratiotable8,
    9: gtagratiotable9
  };

  let finaldriveadjustable = topspeed * finaldrive

  var calculatedtospeedkmh = (gtagratiotables[gtagratiotableIndex][gearcalc] * finaldriveadjustable) / gearratiotable;
  var topspeedgear = Math.floor((calculatedtospeedkmh * 0.9) / gtagratiotables[gtagratiotableIndex][gearcalc]);

  if (isNaN(topspeedgear)) {
    var topspeedgear = 0
  }

  return topspeedgear;
}

function handleSubmit(event) {
  event.preventDefault();

  var formData = new FormData(event.target);
  var formProps = Object.fromEntries(formData);

  fetch(`https://${GetParentResourceName()}/submitVehicleConfig`, {
      method: 'POST',
      headers: {
          'Content-Type': 'application/json'
      },
      body: JSON.stringify(formProps)
  })
  .then(response => response.json())
  .then(data => {
      console.log('Success:', data);
  })
  .catch((error) => {
      console.error('Error:', error);
  });

  closeForm();
}

function updateLabelForGear(gearNumber) {
  let gearValue = parseFloat(document.getElementById('gear' + gearNumber).value);
  let finaldrive = parseFloat(document.getElementById('finaldrive').value);
  let topSpeed = calculateTopSpeed(gears, finaldrive, gearValue, gearNumber, speed);
  let ordinal = (gearNumber === 1) ? 'st' :
  (gearNumber === 2) ? 'nd' :
  (gearNumber === 3) ? 'rd' : 'th';
  let gearText = (gearNumber >= 1) ? `${gearNumber}${ordinal}` : 'R';
  
  document.getElementById('labelg' + (gearNumber)).textContent = `${gearText} (${topSpeed} KM/H)`;

}

document.getElementById('gear0').addEventListener('input', function() {
  updateLabelForGear(0);
});
document.getElementById('gear1').addEventListener('input', function() {
  updateLabelForGear(1);
});
document.getElementById('gear2').addEventListener('input', function() {
  updateLabelForGear(2);
});
document.getElementById('gear3').addEventListener('input', function() {
  updateLabelForGear(3);
});
document.getElementById('gear4').addEventListener('input', function() {
  updateLabelForGear(4);
});
document.getElementById('gear5').addEventListener('input', function() {
  updateLabelForGear(5);
});
document.getElementById('gear6').addEventListener('input', function() {
  updateLabelForGear(6);
});
document.getElementById('gear7').addEventListener('input', function() {
  updateLabelForGear(7);
});
document.getElementById('gear8').addEventListener('input', function() {
  updateLabelForGear(8);
});
document.getElementById('gear9').addEventListener('input', function() {
  updateLabelForGear(9);
});
document.getElementById('finaldrive').addEventListener('input', function() {
  updateLabelForGear(1);
  updateLabelForGear(2);
  updateLabelForGear(3);
  updateLabelForGear(4);
  updateLabelForGear(5);
  updateLabelForGear(6);
  updateLabelForGear(7);
  updateLabelForGear(8);
  updateLabelForGear(9);
  updateLabelForGear(0);
});