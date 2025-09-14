class HolmesGPTClient {
    constructor () {
        this.apiBase = '/api';
        this.messagesContainer = document.getElementById('messages');
        this.messageInput = document.getElementById('messageInput');
        this.sendButton = document.getElementById('sendButton');
        this.chatForm = document.getElementById('chatForm');
        this.statusIndicator = document.getElementById('statusIndicator');
        this.statusText = document.getElementById('statusText');
        this.modelInfo = document.getElementById('modelInfo');

        this.isConnected = false;
        this.isLoading = false;

        this.init();
    }

    async init () {
        this.setupEventListeners();
        await this.checkConnection();
        await this.loadModelInfo();
    }

    setupEventListeners () {
        // Chat form submission
        this.chatForm.addEventListener('submit', (e) => {
            e.preventDefault();
            this.sendMessage();
        });

        // Input field changes
        this.messageInput.addEventListener('input', () => {
            this.updateSendButton();
        });

        // Quick action buttons
        document.querySelectorAll('.quick-action-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const query = btn.getAttribute('data-query');
                this.messageInput.value = query;
                this.updateSendButton();
                this.sendMessage();
            });
        });

        // Enter key handling
        this.messageInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                if (!this.isLoading && this.messageInput.value.trim()) {
                    this.sendMessage();
                }
            }
        });
    }

    updateSendButton () {
        const hasText = this.messageInput.value.trim().length > 0;
        this.sendButton.disabled = !hasText || this.isLoading || !this.isConnected;
    }

    async checkConnection () {
        try {
            const response = await fetch(`${this.apiBase}/model`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                },
            });

            if (response.ok) {
                this.setConnectionStatus(true, 'Connected');
                this.isConnected = true;
            } else {
                throw new Error(`HTTP ${response.status}`);
            }
        } catch (error) {
            console.error('Connection check failed:', error);
            this.setConnectionStatus(false, 'Connection Failed');
            this.isConnected = false;
        }

        this.updateSendButton();
    }

    async loadModelInfo () {
        try {
            const response = await fetch(`${this.apiBase}/model`);
            if (response.ok) {
                const data = await response.json();
                const modelName = JSON.parse(data.model_name)[0] || 'Unknown';
                this.modelInfo.textContent = modelName;
            }
        } catch (error) {
            console.error('Failed to load model info:', error);
            this.modelInfo.textContent = 'Unknown';
        }
    }

    setConnectionStatus (connected, text) {
        this.statusIndicator.className = `status-indicator ${connected ? 'connected' : 'error'}`;
        this.statusText.textContent = text;
    }

    async sendMessage () {
        const message = this.messageInput.value.trim();
        if (!message || this.isLoading || !this.isConnected) return;

        // Add user message to chat
        this.addMessage(message, 'user');

        // Clear input and show loading
        this.messageInput.value = '';
        this.updateSendButton();
        this.setLoading(true);

        // Add loading message
        const loadingId = this.addLoadingMessage();

        try {
            const response = await fetch(`${this.apiBase}/chat`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ ask: message })
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const data = await response.json();

            // Remove loading message and add response
            this.removeMessage(loadingId);
            this.addMessage(data.analysis || 'No response received', 'assistant');

        } catch (error) {
            console.error('API Error:', error);
            this.removeMessage(loadingId);
            this.addMessage(
                `Sorry, I encountered an error: ${error.message}. Please make sure the HolmesGPT API is running and accessible.`,
                'assistant',
                true
            );
        } finally {
            this.setLoading(false);
        }
    }

    addMessage (content, type, isError = false) {
        const messageId = `msg-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${type}-message`;
        messageDiv.id = messageId;

        const iconClass = type === 'user' ? 'fa-user' : 'fa-robot';

        messageDiv.innerHTML = `
            <div class="message-icon">
                <i class="fas ${iconClass}"></i>
            </div>
            <div class="message-content ${isError ? 'error-message' : ''}">
                ${this.formatMessage(content)}
            </div>
        `;

        this.messagesContainer.appendChild(messageDiv);
        this.scrollToBottom();

        return messageId;
    }

    addLoadingMessage () {
        const messageId = `loading-${Date.now()}`;
        const messageDiv = document.createElement('div');
        messageDiv.className = 'message assistant-message';
        messageDiv.id = messageId;

        messageDiv.innerHTML = `
            <div class="message-icon">
                <i class="fas fa-robot"></i>
            </div>
            <div class="message-content">
                <div class="loading">
                    <div class="loading-dot"></div>
                    <div class="loading-dot"></div>
                    <div class="loading-dot"></div>
                </div>
                <p style="margin-top: 8px; color: #6b7280; font-size: 14px;">HolmesGPT is thinking...</p>
            </div>
        `;

        this.messagesContainer.appendChild(messageDiv);
        this.scrollToBottom();

        return messageId;
    }

    removeMessage (messageId) {
        const message = document.getElementById(messageId);
        if (message) {
            message.remove();
        }
    }

    formatMessage (content) {
        // Convert newlines to paragraphs
        const paragraphs = content.split('\n').filter(p => p.trim());
        return paragraphs.map(p => `<p>${this.escapeHtml(p)}</p>`).join('');
    }

    escapeHtml (text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    setLoading (loading) {
        this.isLoading = loading;
        this.messageInput.disabled = loading;
        this.updateSendButton();

        // Update status
        if (loading) {
            this.setConnectionStatus(true, 'Processing...');
        } else {
            this.setConnectionStatus(true, 'Connected');
        }
    }

    scrollToBottom () {
        setTimeout(() => {
            this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight;
        }, 100);
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new HolmesGPTClient();
});

// Handle connection retry
setInterval(async () => {
    const client = window.holmesClient;
    if (client && !client.isConnected && !client.isLoading) {
        await client.checkConnection();
    }
}, 30000); // Check every 30 seconds
