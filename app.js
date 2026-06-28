const app = document.getElementById('app');
const characterList = document.getElementById('character-list');

window.addEventListener('message', function (event) {
    const { action, data } = event.data;

    if (action === 'open') {
        app.classList.remove('hidden');
        renderCharacters(data.characters || [], data.maxSlots || 4);
    }

    if (action === 'close') {
        app.classList.add('hidden');
    }

    if (action === 'refreshCharacters') {
        renderCharacters(data.characters || [], 4);
    }
});

function renderCharacters(characters, maxSlots) {
    characterList.innerHTML = '';

    for (let i = 1; i <= maxSlots; i++) {
        const char = characters[i];
        const card = document.createElement('div');
        card.className = `character-card ${char ? '' : 'empty'}`;

        if (char) {
            card.innerHTML = `
                <div>
                    <strong>${char.name}</strong><br>
                    CID: ${char.cid}<br>
                    Citizen ID: ${char.citizenid}
                </div>
                <div>
                    <button onclick="selectCharacter('${char.citizenid}')">Play</button>
                    <button onclick="deleteCharacter('${char.citizenid}')">Delete</button>
                </div>
            `;
        } else {
            card.innerHTML = `
                <div>
                    <strong>Empty Slot ${i}</strong>
                </div>
            `;
        }

        characterList.appendChild(card);
    }
}

function post(eventName, data = {}) {
    fetch(`[${getparentresourcename()}](https://${GetParentResourceName()}/${eventName})`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });
}

function selectCharacter(citizenid) {
    post('selectCharacter', { citizenid });
}

function deleteCharacter(citizenid) {
    post('deleteCharacter', { citizenid });
}

function createCharacter() {
    const firstname = document.getElementById('firstname').value;
    const lastname = document.getElementById('lastname').value;
    const birthdate = document.getElementById('birthdate').value;
    const gender = document.getElementById('gender').value;
    const nationality = document.getElementById('nationality').value;
    const cid = document.getElementById('cid').value;

    post('createCharacter', {
        firstname,
        lastname,
        birthdate,
        gender,
        nationality,
        cid
    });
}
