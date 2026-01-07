---
title: "Cara Membuat Blog Post Baru di Kelas TKJ"
description: "Tutorial lengkap cara menambahkan artikel baru menggunakan Markdown files"
pubDate: 2026-01-05
author: "Admin"
tags: ["tutorial", "blog", "markdown"]
featured: false
---

# 📝 Cara Membuat Blog Post Baru

Website Kelas TKJ menggunakan **Markdown** untuk blog posts. Ini memudahkan siapa saja untuk menulis artikel tanpa perlu coding!

## 🚀 Quick Start

### 1. Buat File Markdown Baru

Buat file baru di folder `src/content/blog/` dengan format:
```
nama-artikel-anda.md
```

### 2. Tambahkan Frontmatter

Di bagian atas file, tambahkan metadata:

```markdown
---
title: "Judul Artikel Anda"
description: "Deskripsi singkat artikel"
pubDate: 2026-01-05
author: "Nama Anda"
tags: ["tag1", "tag2"]
featured: false
---
```

### 3. Tulis Konten

Setelah frontmatter, tulis konten artikel menggunakan Markdown:

```markdown
# Heading 1
## Heading 2
### Heading 3

**Bold text**
*Italic text*

- List item 1
- List item 2

1. Numbered list
2. Item 2

[Link text](https://example.com)

![Alt text](/path/to/image.jpg)
```

## 📚 Markdown Cheat Sheet

### Text Formatting

```markdown
**Bold**
*Italic*
***Bold & Italic***
~~Strikethrough~~
`Inline code`
```

### Lists

```markdown
- Unordered list
- Item 2
  - Nested item

1. Ordered list
2. Item 2
```

### Links & Images

```markdown
[Link text](https://example.com)
![Image alt](image.jpg)
```

### Code Blocks

\`\`\`javascript
const hello = "world";
console.log(hello);
\`\`\`

### Blockquotes

```markdown
> This is a quote
> Multiple lines
```

### Tables

```markdown
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
```

## 🎨 Tips Menulis Artikel yang Baik

1. **Judul yang Menarik**: Buat judul yang jelas dan menarik perhatian
2. **Deskripsi Singkat**: Tulis deskripsi 1-2 kalimat yang merangkum artikel
3. **Struktur Jelas**: Gunakan heading untuk membagi section
4. **Visual**: Tambahkan emoji atau gambar untuk menarik
5. **Tags Relevan**: Pilih 3-5 tags yang sesuai

## ✅ Checklist Sebelum Publish

- [ ] Frontmatter lengkap dan benar
- [ ] Judul menarik dan deskriptif
- [ ] Konten terstruktur dengan heading
- [ ] Tidak ada typo
- [ ] Tags relevan
- [ ] Tanggal publish benar

## 🔥 Contoh Artikel Bagus

Lihat artikel "Mengenal Game Zone" sebagai referensi struktur artikel yang baik!

---

*Happy writing!* ✍️
