let projects = JSON.parse(localStorage.getItem('projects')) || [];
let editingId = null;

const form = document.querySelector('#projectForm');
const nameInput = document.querySelector('#projectName');
const descInput = document.querySelector('#projectDescription');
const statusSelect = document.querySelector('#projectStatus');
const dueDateInput = document.querySelector('#projectDueDate');
const tbody = document.querySelector('#projectTableBody');
const emptyMsg = document.querySelector('#emptyMessage')

function saveProjects(){
    localStorage.setItem('projects', JSON.stringify(projects));
}

function renderTable(){
    tbody.innerHTML = '';

    if(projects.length === 0){
        emptyMsg.classList.remove('hidden');
        return
    }
    emptyMsg.classList.add('hidden');

    projects.forEach((project, index) => {
        const row = document.createElement('tr');
        row.className = 'border-b border-gray-200';

        row.innerHTML = `
        <td class="px-4 py-3 text-sm">${project.name}</td>
        <td class="px-4" py-3 text-sm>${project.description || '-'}</td>
        <td class="px-4 py-3 text-sm">
            <span class="px-2 py-1 rounded-full text-sx font-semibold bg-yellow-200 text-yellow-800">${project.status}</span>
        </td>
        <td class="px-4 py-3 text-sm">${project.dueDate}</td>
        <td class="px-4 py-3 text-sm">
        <button class="edit-btn text-indigo-600 hover:text-indigo-800 mr-3" data-id="${project.id}">Edit</button>
        <button class="delete-btn text-red-600 hover:text-red-800" data-id="${project.id}">Delete</button>
        </td>
        `;
        tbody.appendChild(row);
    });

    document.querySelectorAll('.delete-btn').forEach(button => {
        button.addEventListener('click', function() {
            const id = Number(this.dataset.id);
            if (confirm('Delete this project?')) {
                projects = projects.filter(p => p.id !== id);
                saveProjects();
                renderTable();
            }
        });
    });

    document.querySelectorAll('.edit-btn').forEach(button => {
        button.addEventListener('click', function(){
            const id = Number(this.dataset.id);
            const project = projects.find(p => p.id === id);
            if(!project) return;

            nameInput.value = project.name;
            descInput.value = project.description || '';
            statusSelect.value = project.status;
            dueDateInput.value = project.dueDate;

            editingId = id;

            document.querySelector('#addBtn').textContent = 'Update Project';
         });
    });

}
form.addEventListener('submit', function(event){
        event.preventDefault();

        const name = nameInput.value.trim();
        const desc = descInput.value.trim();
        const status = statusSelect.value;
        const dueDate = dueDateInput.value;

        if(name === '' || dueDate === ''){
            alert('Please fill in the Project Name and Due Date.');
            return
        }

        if(editingId === null){
            const newProject = {
            id: Date.now(),
            name: name,
            description: desc,
            status: status,
            dueDate: dueDate
        };
        projects.push(newProject);
        } else {
            const index = projects.findIndex(p => p.id === editingId);
            if(index !== -1){
                projects[index] = {
                    id: editingId,
                    name: name,
                    description: desc,
                    status: status,
                    dueDate: dueDate
                }
            }
        }
        editingId = null;
        document.querySelector('#addBtn').textContent = 'Add Project'

        saveProjects();
        renderTable();
        form.reset();
    });
renderTable();
