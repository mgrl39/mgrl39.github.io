// Variables globales
let config = {
    username: 'mgrl39',
    featuredRepos: [],
    subdomains: []
};
let allRepos = [];
let currentView = 'repos'; // 'repos' o 'subdomains'

// Cargar configuración desde details.json
async function loadConfig() {
    try {
        const response = await fetch('details.json');
        if (!response.ok) {
            throw new Error('No se pudo cargar el archivo de configuración');
        }
        config = await response.json();
        
        // Actualizar elementos de UI con la configuración
        document.querySelector('h1').textContent = config.title || config.username;
        if (config.subtitle) {
            document.querySelector('p.text-gray-400').textContent = config.subtitle;
        }
        if (config.footer) {
            document.querySelector('footer .container').innerHTML = config.footer;
        }
        
        // Añadir switch de vista si hay subdominios
        if (config.subdomains && config.subdomains.length > 0) {
            addViewSwitcher();
        }
        
        return true;
    } catch (error) {
        console.error('Error cargando configuración:', error);
        return false;
    }
}

// Añadir switcher entre repos y subdominios
function addViewSwitcher() {
    const searchContainer = document.querySelector('.command-palette');
    
    // Añadir tabs sobre el buscador
    const tabsContainer = document.createElement('div');
    tabsContainer.className = 'flex border-b border-gray-800';
    tabsContainer.innerHTML = `
        <button id="tab-repos" class="px-4 py-2 text-sm font-medium focus:outline-none ${currentView === 'repos' ? 'text-accent border-b-2 border-accent' : 'text-gray-400 hover:text-white'}">
            <i class="fas fa-code-branch mr-2"></i>Repositorios
        </button>
        <button id="tab-subdomains" class="px-4 py-2 text-sm font-medium focus:outline-none ${currentView === 'subdomains' ? 'text-accent border-b-2 border-accent' : 'text-gray-400 hover:text-white'}">
            <i class="fas fa-globe mr-2"></i>Subdominios
        </button>
    `;
    
    searchContainer.prepend(tabsContainer);
    
    // Añadir event listeners
    document.getElementById('tab-repos').addEventListener('click', () => {
        setCurrentView('repos');
    });
    
    document.getElementById('tab-subdomains').addEventListener('click', () => {
        setCurrentView('subdomains');
    });
}

// Cambiar entre vistas
function setCurrentView(view) {
    currentView = view;
    
    // Actualizar tabs
    const reposTab = document.getElementById('tab-repos');
    const subdomainsTab = document.getElementById('tab-subdomains');
    
    if (reposTab && subdomainsTab) {
        if (view === 'repos') {
            reposTab.className = 'px-4 py-2 text-sm font-medium focus:outline-none text-accent border-b-2 border-accent';
            subdomainsTab.className = 'px-4 py-2 text-sm font-medium focus:outline-none text-gray-400 hover:text-white';
            
            // Mostrar buscador y cambiar placeholder
            document.getElementById('search-input').placeholder = 'Buscar repositorios';
            document.querySelector('.command-palette > div:nth-child(2)').classList.remove('hidden');
        } else {
            reposTab.className = 'px-4 py-2 text-sm font-medium focus:outline-none text-gray-400 hover:text-white';
            subdomainsTab.className = 'px-4 py-2 text-sm font-medium focus:outline-none text-accent border-b-2 border-accent';
            
            // Mostrar buscador y cambiar placeholder
            document.getElementById('search-input').placeholder = 'Buscar subdominios';
            document.querySelector('.command-palette > div:nth-child(2)').classList.remove('hidden');
        }
    }
    
    // Actualizar contenido
    if (view === 'repos') {
        // Si ya tenemos repos cargados, mostrarlos
        if (allRepos.length > 0) {
            displayFeaturedRepos();
        } else {
            loadRepositories();
        }
    } else {
        displaySubdomains();
    }
}

// Mostrar subdominios
function displaySubdomains() {
    const container = document.getElementById('results-container');
    container.innerHTML = '';
    
    if (!config.subdomains || config.subdomains.length === 0) {
        container.innerHTML = `
            <div class="p-4 text-center text-gray-500">
                No hay subdominios configurados
            </div>
        `;
        return;
    }
    
    // Filtrar subdominios si hay una búsqueda
    const query = document.getElementById('search-input').value.toLowerCase().trim();
    const subdomainsToShow = query ? 
        config.subdomains.filter(sub => 
            sub.name.toLowerCase().includes(query) || 
            (sub.description && sub.description.toLowerCase().includes(query))
        ) : 
        config.subdomains;
    
    if (subdomainsToShow.length === 0) {
        container.innerHTML = `
            <div class="p-4 text-center text-gray-500">
                No se encontraron subdominios que coincidan con "<span class="text-accent">${query}</span>"
            </div>
        `;
        return;
    }
    
    // Renderizar subdominios
    subdomainsToShow.forEach((subdomain, index) => {
        const item = document.createElement('div');
        item.className = 'border-b border-gray-800 last:border-b-0 hover:bg-card p-3 transition-colors result-item';
        item.style.animationDelay = `${index * 0.05}s`;
        
        item.innerHTML = `
            <a href="${subdomain.url}" class="flex items-start group" target="_blank">
                <div class="mr-3 mt-1">
                    <i class="${subdomain.icon || 'fas fa-globe'} text-accent"></i>
                </div>
                <div class="flex-1">
                    <h3 class="font-medium text-white group-hover:text-accent transition-colors">${subdomain.name}</h3>
                    <p class="text-gray-400 text-sm">${subdomain.description || ''}</p>
                </div>
                <div class="ml-3 text-gray-600 group-hover:text-accent transition-colors">
                    <i class="fas fa-external-link-alt"></i>
                </div>
            </a>
        `;
        
        container.appendChild(item);
    });
}

// Efectos de mouse
const mouseGlow = document.getElementById('mouse-glow');
document.addEventListener('mousemove', (e) => {
    const x = (e.clientX / window.innerWidth) * 100;
    const y = (e.clientY / window.innerHeight) * 100;
    mouseGlow.style.setProperty('--x', x + '%');
    mouseGlow.style.setProperty('--y', y + '%');
    
    // Mostrar gradualmente el efecto después de cargar la página
    if (mouseGlow.classList.contains('opacity-0')) {
        setTimeout(() => {
            mouseGlow.classList.remove('opacity-0');
        }, 500);
    }
});

// Abrir paleta con Ctrl+K o Command+K
document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        document.getElementById('search-input').focus();
    }
    
    // Cerrar con Escape
    if (e.key === 'Escape') {
        document.getElementById('search-input').blur();
    }
});

// Búsqueda en tiempo real
document.getElementById('search-input').addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase().trim();
    
    if (currentView === 'repos') {
        filterRepositories(query);
    } else {
        displaySubdomains(); // La función ya incluye filtrado
    }
});

// Filtrar repositorios según búsqueda
function filterRepositories(query) {
    const resultsContainer = document.getElementById('results-container');
    
    if (!allRepos.length) {
        resultsContainer.innerHTML = `
            <div class="p-4 text-center text-gray-500">
                No se han cargado repositorios aún
            </div>
        `;
        return;
    }
    
    // Si no hay búsqueda, mostrar destacados
    if (!query) {
        displayFeaturedRepos();
        return;
    }
    
    // Filtrar repos según la búsqueda
    const filteredRepos = allRepos.filter(repo => 
        repo.name.toLowerCase().includes(query) || 
        (repo.description && repo.description.toLowerCase().includes(query))
    );
    
    if (filteredRepos.length === 0) {
        resultsContainer.innerHTML = `
            <div class="p-4 text-center text-gray-500">
                No se encontraron repositorios que coincidan con "<span class="text-accent">${query}</span>"
            </div>
        `;
        return;
    }
    
    renderRepositories(filteredRepos);
}

// Mostrar repos destacados
function displayFeaturedRepos() {
    const featured = [];
    
    // Primero intentar encontrar los destacados específicos
    for (const name of config.featuredRepos) {
        const found = allRepos.find(repo => 
            repo.name.toLowerCase().includes(name.toLowerCase())
        );
        if (found) featured.push(found);
    }
    
    // Si no hay suficientes, mostrar los más recientes
    if (featured.length === 0) {
        const nonForks = allRepos.filter(repo => !repo.fork).slice(0, 5);
        renderRepositories(nonForks);
    } else {
        renderRepositories(featured);
    }
}

// Renderizar la lista de repositorios
function renderRepositories(repos) {
    const container = document.getElementById('results-container');
    container.innerHTML = '';
    
    repos.forEach((repo, index) => {
        // Formatear nombre
        const formattedName = repo.name
            .replace(/-/g, ' ')
            .replace(/_/g, ' ')
            .split(' ')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
        
        const item = document.createElement('div');
        item.className = 'border-b border-gray-800 last:border-b-0 hover:bg-card p-3 transition-colors result-item';
        item.style.animationDelay = `${index * 0.05}s`;
        
        item.innerHTML = `
            <a href="${repo.html_url}" class="flex items-start group" target="_blank">
                <div class="mr-3 mt-1">
                    <i class="far fa-folder text-accent"></i>
                </div>
                <div class="flex-1 min-w-0">
                    <div class="flex items-center">
                        <h3 class="font-medium text-white truncate group-hover:text-accent transition-colors mr-2">${formattedName}</h3>
                        ${repo.language ? `<span class="text-xs bg-gray-800 rounded-full px-2 py-1">${repo.language}</span>` : ''}
                    </div>
                    <p class="text-gray-400 text-sm truncate">${repo.description || 'Sin descripción'}</p>
                    <div class="flex mt-2 text-xs text-gray-500">
                        <span class="mr-3"><i class="far fa-star mr-1"></i>${repo.stargazers_count}</span>
                        <span><i class="fas fa-code-branch mr-1"></i>${repo.forks_count}</span>
                        <span class="ml-auto">${new Date(repo.updated_at).toLocaleDateString()}</span>
                    </div>
                </div>
                <div class="ml-3 text-gray-600 group-hover:text-accent transition-colors">
                    <i class="fas fa-external-link-alt"></i>
                </div>
            </a>
        `;
        
        container.appendChild(item);
    });
}

// Cargar datos de GitHub
async function loadRepositories() {
    const container = document.getElementById('results-container');
    container.innerHTML = `
        <div id="loading" class="p-4 text-center text-gray-400">
            <i class="fas fa-spinner fa-spin mr-2"></i> Cargando...
        </div>
    `;
    
    try {
        const response = await fetch(`https://api.github.com/users/${config.username}/repos?sort=updated&per_page=100`);
        
        if (!response.ok) {
            throw new Error('Error al cargar repositorios');
        }
        
        allRepos = await response.json();
        
        // Mostrar repos destacados al inicio
        displayFeaturedRepos();
        
    } catch (error) {
        container.innerHTML = `
            <div class="p-4 text-center text-red-500">
                <i class="fas fa-exclamation-circle mr-2"></i>
                Error al cargar repositorios: ${error.message}
            </div>
        `;
    }
}

// Inicializar
document.addEventListener('DOMContentLoaded', async () => {
    // Primero cargar la configuración
    await loadConfig();
    
    // Configurar los botones de pestaña
    document.getElementById('tab-repos').addEventListener('click', () => {
        setCurrentView('repos');
    });
    
    document.getElementById('tab-subdomains').addEventListener('click', () => {
        setCurrentView('subdomains');
    });
    
    // Iniciar con la vista de repositorios
    setCurrentView('repos');
    
    // Enfocar automáticamente el buscador
    setTimeout(() => document.getElementById('search-input').focus(), 300);
}); 