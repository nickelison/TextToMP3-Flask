function deleteMp3File(deleteBtn) {
    var mp3Id = deleteBtn.id.split('-')[1];

    fetch('/delete/' + mp3Id, {
        method: 'POST',
        headers: {
            'Accept': 'application/json, text/plain, */*',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({data: null})
    }).then(function(res) {
        return res.json();
    }).then(function(data) {
        if (data['status'] === 'success') {
            document.getElementById('row-' + mp3Id).remove()
        }
    })
}
