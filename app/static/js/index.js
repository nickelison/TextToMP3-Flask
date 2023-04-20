function deleteName(nameId) {
    fetch('/delete/', {
        method: 'POST',
        headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(
        {
            name_id: nameId
        })
    }).then(function(res) {
        return res.json();
    }).then(function(data) {
        //console.log(data);

        if (data['status'] === 'success') {
            rowElm = document.getElementById('row-' + nameId);
            rowElm.remove();
        }
    });
}
