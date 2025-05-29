import React, { useRef, useEffect, useState } from 'react';

const myName = '나';
const otherName = '김민영';
const otherProfile = '🐰'; // 예시: 이모지, 실제로는 이미지 가능

const initialMessages = [
  { id: 1, sender: otherName, text: '언니 피자 뭐야? ㅋㅋㅋㅋㅋㅋ', time: '오후 7:01' },
  { id: 2, sender: myName, text: '피자 먹고 싶어서 피자로 했지', time: '오후 7:01' },
  { id: 3, sender: otherName, text: '아 ㅋㅋㅋ 먹으러 가장~~~ 내일 어때', time: '오후 7:02' },
  { id: 4, sender: myName, text: 'There are many programming languages in the market that are used in designing and building websites, various applications and other uses. These languages are popular in their place and in the way they are used, and many programmers learn and use them.', time: '오후 7:03' },
  { id: 5, sender: otherName, text: '웅 해영 당빠지나바', time: '오후 7:03' },
  { id: 6, sender: myName, text: 'There are many programming languages in the market that are used in designing and building websites, various applications and other uses. These languages are popular in their place and in the way they are used, and many programmers learn and use them.', time: '오후 7:04' },
];

export default function ChatScreen({ onBack }: { onBack?: () => void }) {
  const [messages, setMessages] = useState(initialMessages);
  const [input, setInput] = useState('');
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSend = () => {
    if (!input.trim()) return;
    setMessages([...messages, { id: Date.now(), sender: myName, text: input, time: '오후 7:05' }]);
    setInput('');
  };

  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] h-[844px] w-full bg-white shadow-2xl rounded-[24px] flex flex-col overflow-hidden relative">
        {/* 상단 헤더 */}
        <div className="flex items-center gap-2 px-4 pt-6 pb-2 bg-white z-10 border-b border-[#F2F4F6]">
          <button onClick={onBack} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
          <span className="text-2xl">{otherProfile}</span>
          <div className="flex-1 flex flex-col">
            <span className="text-base font-bold text-[#191F28] leading-tight">{otherName}</span>
            <span className="text-xs text-[#5AC4FF] font-bold">• Online</span>
          </div>
        </div>
        {/* 채팅 메시지 영역 */}
        <div className="flex-1 overflow-y-auto px-3 py-4 space-y-2 bg-[#F9FAFB]">
          {messages.map(msg => (
            <div key={msg.id} className={`flex ${msg.sender === myName ? 'justify-end' : 'justify-start'}`}>
              {msg.sender !== myName && <span className="text-2xl mr-2">{otherProfile}</span>}
              <div className={`max-w-[70%] rounded-2xl px-4 py-2 text-sm whitespace-pre-line break-words ${msg.sender === myName ? 'bg-[#F2F4F6] text-[#191F28] rounded-br-md' : 'bg-[#FA2E55] text-white rounded-bl-md'}`}>
                {msg.text}
              </div>
            </div>
          ))}
          <div ref={bottomRef} />
        </div>
        {/* 입력창 */}
        <form className="flex items-center gap-2 px-4 py-3 bg-white border-t border-[#F2F4F6]" onSubmit={e => { e.preventDefault(); handleSend(); }}>
          <input
            className="flex-1 h-11 rounded-full border border-[#E5E8EB] bg-[#F9FAFB] px-4 text-sm text-[#191F28] focus:outline-none focus:border-[#FA2E55]"
            placeholder="Write your message"
            value={input}
            onChange={e => setInput(e.target.value)}
            autoFocus
          />
          <button type="submit" className="w-11 h-11 rounded-full bg-[#FA2E55] flex items-center justify-center text-white text-xl active:scale-95 transition">
            <span className="material-icons">arrow_upward</span>
          </button>
        </form>
      </div>
    </div>
  );
} 