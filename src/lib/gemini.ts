// Gemini AI API Utility
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

export async function generateQuestion(category: string): Promise<string> {
    const apiKey = import.meta.env.PUBLIC_GEMINI_API_KEY;
    
    if (!apiKey) {
        console.warn('Gemini API key not found, using fallback');
        return getFallbackQuestion(category);
    }

    const prompt = `Kamu adalah pembuat pertanyaan untuk game Fakeit (mirip game viral di TikTok).
Buat 1 pertanyaan UNIK dan MENARIK untuk kategori "${category}".

Aturan:
- Pertanyaan harus dalam Bahasa Indonesia
- Pertanyaan harus personal dan mudah dijawab semua orang
- Pertanyaan TIDAK boleh terlalu spesifik atau teknis
- Pertanyaan harus FUN dan bisa memancing berbagai jawaban
- Jangan gunakan pertanyaan yang terlalu umum seperti "apa makanan favorit?"
- Buat pertanyaan yang kreatif dan unik

Contoh pertanyaan bagus untuk kategori Makanan:
- "Makanan apa yang kamu makan diam-diam biar ga diminta orang lain?"
- "Kalau dunia kiamat besok, makanan terakhir yang mau kamu makan apa?"

HANYA OUTPUT PERTANYAAN SAJA, tanpa tanda kutip, tanpa penjelasan.`;

    try {
        const response = await fetch(`${GEMINI_API_URL}?key=${apiKey}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                contents: [{
                    parts: [{ text: prompt }]
                }],
                generationConfig: {
                    temperature: 0.9,
                    maxOutputTokens: 100,
                }
            })
        });

        if (!response.ok) {
            throw new Error(`API error: ${response.status}`);
        }

        const data = await response.json();
        const text = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
        
        if (text) {
            // Clean up the response
            return text.replace(/^["']|["']$/g, '').trim();
        }
        
        throw new Error('Empty response');
    } catch (error) {
        console.error('Gemini API error:', error);
        return getFallbackQuestion(category);
    }
}

// Fallback questions if API fails
function getFallbackQuestion(category: string): string {
    const fallbacks: Record<string, string[]> = {
        'Makanan': [
            'Makanan apa yang bikin kamu kangen rumah?',
            'Kalau cuma boleh makan 1 makanan seumur hidup, pilih apa?',
            'Makanan apa yang selalu bikin mood kamu membaik?'
        ],
        'Tempat': [
            'Tempat apa yang pengen banget kamu kunjungi sebelum umur 30?',
            'Kalau bisa teleport sekarang, mau ke mana?',
            'Tempat mana yang selalu bikin kamu tenang?'
        ],
        'Hewan': [
            'Kalau bisa jadi hewan sehari, mau jadi apa?',
            'Hewan apa yang paling menggambarkan kepribadianmu?',
            'Hewan peliharaan impian yang belum kesampaian?'
        ],
        'Film & Musik': [
            'Lagu apa yang menggambarkan hidupmu sekarang?',
            'Film apa yang bisa kamu tonton berkali-kali tanpa bosan?',
            'Soundtrack hidup kamu apa?'
        ],
        'Sekolah': [
            'Moment paling memalukan di sekolah?',
            'Guru yang paling berkesan dan kenapa?',
            'Kalau bisa mengulang masa sekolah, apa yang mau diubah?'
        ],
        'Teknologi': [
            'Aplikasi pertama yang dibuka tiap pagi apa?',
            'Gadget apa yang ga bisa hidup tanpanya?',
            'Social media mana yang paling menghabiskan waktumu?'
        ]
    };

    const questions = fallbacks[category] || fallbacks['Makanan'];
    return questions[Math.floor(Math.random() * questions.length)];
}
