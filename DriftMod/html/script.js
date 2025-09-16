document.addEventListener('DOMContentLoaded', () => {
    const menu = document.getElementById('drift-menu');
    const closeBtn = document.getElementById('close-btn');
    const sliders = document.querySelectorAll('input[type="range"]');
    const presetButtons = document.querySelectorAll('.preset-btn');
    const rebindButton = document.getElementById('rebind-key');
    const resetButton = document.getElementById('reset-defaults');
    const toggleStatus = document.getElementById('toggle-status');
    const holdStatus = document.getElementById('hold-status');

    // Função para fazer POST para o client script
    const post = (event, data = {}) => {
        fetch(`https://DriftMod2.0/${event}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data)
        });
    };

    const toggleMenu = (show) => {
        if (show) {
            document.body.style.display = 'flex';
            setTimeout(() => {
                menu.classList.add('show');
            }, 50);
        } else {
            menu.classList.remove('show');
            setTimeout(() => {
                document.body.style.display = 'none';
            }, 300); // Espera a animação de 'hide' terminar
        }
    };

    // Função para atualizar valor do slider
    const updateSliderValue = (slider) => {
        const valueSpan = document.getElementById(`${slider.id}Value`);
        if (valueSpan) {
            valueSpan.textContent = parseFloat(slider.value).toFixed(2);
        }
    };

    // Função para atualizar status
    const updateStatus = (toggle, hold) => {
        // Toggle status
        if (toggle) {
            toggleStatus.classList.remove('off');
            toggleStatus.classList.add('on');
            toggleStatus.querySelector('span').textContent = 'ON';
        } else {
            toggleStatus.classList.remove('on');
            toggleStatus.classList.add('off');
            toggleStatus.querySelector('span').textContent = 'OFF';
        }

        // Hold status
        if (hold) {
            holdStatus.classList.remove('off');
            holdStatus.classList.add('on');
            holdStatus.querySelector('span').textContent = 'ON';
        } else {
            holdStatus.classList.remove('on');
            holdStatus.classList.add('off');
            holdStatus.querySelector('span').textContent = 'OFF';
        }
    };

    // Função para atualizar sliders
    const updateSliders = (values) => {
        for (const key in values) {
            const slider = document.getElementById(key);
            if (slider) {
                slider.value = values[key];
                updateSliderValue(slider);
            }
        }
    };

    // Função para destacar preset ativo
    const setActivePreset = (presetName) => {
        presetButtons.forEach(btn => {
            if (btn.dataset.preset === presetName) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });
    };

    // Event listeners para sliders
    sliders.forEach(slider => {
        updateSliderValue(slider); // Inicializa o valor
        
        let updateTimeout;
        
        slider.addEventListener('input', () => {
            updateSliderValue(slider);
            
            // Limpa o timeout anterior se existir
            if (updateTimeout) {
                clearTimeout(updateTimeout);
            }
            
            // Cria um novo timeout para atualizar o valor
            updateTimeout = setTimeout(() => {
                post('updateValue', { id: slider.id, value: slider.value });
            }, 100); // Pequeno delay para evitar muitas atualizações
        });
        
        slider.addEventListener('change', () => {
            // Garante que o valor final seja enviado
            clearTimeout(updateTimeout);
            post('updateValue', { id: slider.id, value: slider.value });
            setActivePreset(null); // Remove o destaque do preset ao mudar slider manualmente
            
            // Atualiza o valor original para preview de presets
            const valueSpan = document.getElementById(`${slider.id}Value`);
            if (valueSpan) {
                valueSpan.dataset.originalValue = slider.value;
            }
        });
    });

    // Função para mostrar preview dos valores do preset
    const showPresetPreview = (preset) => {
        const presetValues = {
            'Iniciante': {
                fTractionCurveMax: 0.4,
                fTractionCurveMin: 0.3,
                fTractionLossMult: 2.5,
                fSteeringLock: 40.0
            },
            'Competição': {
                fTractionCurveMax: 0.15,
                fTractionCurveMin: 0.1,
                fTractionLossMult: 6.0,
                fSteeringLock: 50.0
            },
            'Showcase': {
                fTractionCurveMax: 0.05,
                fTractionCurveMin: 0.05,
                fTractionLossMult: 8.0,
                fSteeringLock: 55.0
            },
            'Drift Extremo': {
                fTractionCurveMax: 0.02,
                fTractionCurveMin: 0.01,
                fTractionLossMult: 10.0,
                fSteeringLock: 60.0
            },
            'Drift Suave': {
                fTractionCurveMax: 0.3,
                fTractionCurveMin: 0.25,
                fTractionLossMult: 3.0,
                fSteeringLock: 35.0
            },
            'Drift Profissional': {
                fTractionCurveMax: 0.1,
                fTractionCurveMin: 0.08,
                fTractionLossMult: 7.0,
                fSteeringLock: 52.0
            },
            'Drift Agressivo': {
                fTractionCurveMax: 0.05,
                fTractionCurveMin: 0.03,
                fTractionLossMult: 9.0,
                fSteeringLock: 58.0
            },
            'Drift Controlado': {
                fTractionCurveMax: 0.2,
                fTractionCurveMin: 0.15,
                fTractionLossMult: 5.0,
                fSteeringLock: 45.0
            }
        };

        const values = presetValues[preset];
        if (!values) return;

        sliders.forEach(slider => {
            const currentValue = parseFloat(slider.value);
            const presetValue = values[slider.id];
            const valueSpan = document.getElementById(`${slider.id}Value`);
            
            if (presetValue !== undefined && valueSpan) {
                // Salva o valor atual
                if (!valueSpan.dataset.originalValue) {
                    valueSpan.dataset.originalValue = currentValue;
                }
                
                // Mostra o novo valor em azul
                valueSpan.innerHTML = `<span style="color: var(--primary-color)">${presetValue.toFixed(2)}</span>`;
                
                // Adiciona seta indicando aumento ou diminuição
                if (presetValue > currentValue) {
                    valueSpan.innerHTML += ' ↑';
                } else if (presetValue < currentValue) {
                    valueSpan.innerHTML += ' ↓';
                }
            }
        });
    };

    // Função para restaurar valores originais
    const restoreOriginalValues = () => {
        sliders.forEach(slider => {
            const valueSpan = document.getElementById(`${slider.id}Value`);
            if (valueSpan && valueSpan.dataset.originalValue) {
                valueSpan.textContent = parseFloat(valueSpan.dataset.originalValue).toFixed(2);
                delete valueSpan.dataset.originalValue;
            }
        });
    };

    // Event listeners para presets
    presetButtons.forEach(button => {
        // Mouse over - mostra preview
        button.addEventListener('mouseenter', () => {
            showPresetPreview(button.dataset.preset);
        });

        // Mouse out - restaura valores
        button.addEventListener('mouseleave', () => {
            if (!button.classList.contains('active')) {
                restoreOriginalValues();
            }
        });

        // Click - aplica preset
        button.addEventListener('click', () => {
            // Adiciona efeito visual
            button.style.transform = 'scale(0.95)';
            setTimeout(() => {
                button.style.transform = '';
            }, 150);
            
            const preset = button.dataset.preset;
            setActivePreset(preset);
            post('applyPreset', { preset: preset });
        });
    });

    // Event listener para reset
    resetButton.addEventListener('click', () => {
        resetButton.style.transform = 'scale(0.95)';
        setTimeout(() => {
            resetButton.style.transform = '';
        }, 150);
        
        setActivePreset(null); // Remove destaque ao resetar
        post('resetDefaults');
    });

    // Event listener para rebind de tecla
    rebindButton.addEventListener('click', () => {
        const originalText = rebindButton.innerHTML;
        rebindButton.innerHTML = '<i class="fas fa-keyboard"></i><span>Pressione uma tecla...</span><small>Aguardando...</small>';
        rebindButton.disabled = true;

        const keydownHandler = (e) => {
            e.preventDefault();
            
            // Ignora teclas especiais
            if (e.keyCode && !e.altKey && !e.ctrlKey && !e.shiftKey && e.keyCode < 112) {
                post('setKey', { key: e.keyCode });
                rebindButton.innerHTML = originalText;
                rebindButton.disabled = false;
                window.removeEventListener('keydown', keydownHandler);
            } else if (e.keyCode >= 112 && e.keyCode <= 123) { // Permite F1-F12
                post('setKey', { key: e.keyCode });
                rebindButton.innerHTML = originalText;
                rebindButton.disabled = false;
                window.removeEventListener('keydown', keydownHandler);
            }
        };

        window.addEventListener('keydown', keydownHandler);
    });

    // Event listener para fechar menu
    closeBtn.addEventListener('click', () => {
        post('closeMenu');
    });

    // Event listener para ESC
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            post('closeMenu');
        }
    });

        // --- Listener de Mensagens do LUA ---
    window.addEventListener('message', (event) => {
        const { action, status, currentValues, driftStatus, values } = event.data;

        switch (action) {
            case 'updateVisibility':
                toggleMenu(status);
                if (status) {
                    updateSliders(currentValues);
                    updateStatus(driftStatus.toggle, driftStatus.hold);
                    setActivePreset(null);
                }
                break;
            case 'updateSliders':
                updateSliders(values);
                break;
            case 'updateStatus':
                updateStatus(driftStatus.toggle, driftStatus.hold);
                break;
        }
    });

    // Removido gerenciamento de painel avançado - agora tudo está em uma página

    // Inicializa o menu escondido
    document.body.style.display = 'none';
    console.log('[DriftMod] Menu refeito e carregado com sucesso!');
});