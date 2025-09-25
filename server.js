require('dotenv').config();
const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

// Quotas simples
let quotas = {
    chatgpt: 100,
    claude: 50,
    grok: 50,
    gemini: 50
};

app.post('/prompt', async (req, res) => {
    const { model, prompt } = req.body;

    if (!quotas[model] || quotas[model] <= 0) {
        return res.status(429).json({ error: 'Quota dépassé pour ce modèle' });
    }

    try {
        let responseText = '';

        switch(model){
            case 'chatgpt':
                const chatgptResp = await axios.post(
                    'https://api.openai.com/v1/chat/completions',
                    { model: 'gpt-4', messages: [{ role: 'user', content: prompt }] },
                    { headers: { 'Authorization': `Bearer ${process.env.OPENAI_KEY}` } }
                );
                responseText = chatgptResp.data.choices[0].message.content;
                break;
            case 'claude':
                // API Claude ici
                responseText = `Réponse Claude simulée pour: ${prompt}`;
                break;
            case 'grok':
                // API Grok ici
                responseText = `Réponse Grok simulée pour: ${prompt}`;
                break;
            case 'gemini':
                // API Gemini ici
                responseText = `Réponse Gemini simulée pour: ${prompt}`;
                break;
        }

        quotas[model]--;
        res.json({ answer: responseText });

    } catch (err) {
        res.status(500).json({ error: 'Erreur lors de l’appel à l’IA' });
    }
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
