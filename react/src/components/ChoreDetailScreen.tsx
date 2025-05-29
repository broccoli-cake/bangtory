import React, { useState } from 'react';

interface ChoreDetailScreenProps {
  choreType: string;
  onBack: () => void;
  onDeleteChore?: (choreType: string) => void;
}

const initialSchedules = [
  { date: '2025.05.01.목', name: '김민영', done: true },
  { date: '2025.05.02.금', name: '홍수한', done: true },
  { date: '2025.05.03.토', name: '민수연', done: true },
  { date: '2025.05.04.일', name: '최현경', done: false },
];
const members = ['김민영', '홍수한', '민수연', '최현경'];

export default function ChoreDetailScreen({ choreType, onBack, onDeleteChore }: ChoreDetailScreenProps) {
  const [schedules, setSchedules] = useState(initialSchedules);
  const [showAddForm, setShowAddForm] = useState(true);
  const [addDate, setAddDate] = useState('2025.05.01.목');
  const [addMember, setAddMember] = useState(members[0]);
  const [selectedIdx, setSelectedIdx] = useState<number | null>(null);

  // 체크 토글
  const handleToggleDone = (idx: number) => {
    setSchedules(schs => schs.map((s, i) => i === idx ? { ...s, done: !s.done } : s));
  };
  // 새 일정 등록
  const handleAddSchedule = () => {
    setSchedules(schs => [...schs, { date: addDate, name: addMember, done: false }]);
    setShowAddForm(false);
  };
  // 일정 삭제
  const handleDeleteSchedule = (idx: number) => {
    setSchedules(schs => schs.filter((_, i) => i !== idx));
    setSelectedIdx(null);
  };

  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] w-full h-full bg-white shadow-2xl rounded-[24px] px-4 pt-6 pb-8 flex flex-col justify-start">
        {/* 상단 헤더 */}
        <div className="flex items-center justify-between mb-4">
          <button onClick={onBack} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
          <div className="flex-1 text-center text-lg font-bold text-[#191F28]">{choreType} 당번</div>
          <div className="w-8" />
        </div>
        {/* 등록 일정 */}
        <div className="bg-[#F9FAFB] rounded-xl p-4 mb-4 border border-[#F2F4F6]">
          <div className="text-sm font-bold text-[#191F28] mb-3">등록 일정</div>
          {schedules.map((s, i) => (
            <div
              key={i}
              className={`flex items-center justify-between py-2 px-2 rounded-lg transition cursor-pointer group ${selectedIdx === i ? 'bg-[#FFF0F4] border border-[#FA2E55]' : 'hover:bg-[#F2F4F6]'}`}
              onClick={() => setSelectedIdx(selectedIdx === i ? null : i)}
            >
              <span className="text-[#8B95A1] text-sm">{s.date}</span>
              <span className="text-[#191F28] text-sm font-medium">{s.name}</span>
              <div className="flex items-center gap-2">
                <button onClick={e => { e.stopPropagation(); handleToggleDone(i); }} className={s.done ? 'w-6 h-6 flex items-center justify-center rounded-full bg-[#FA2E55] transition' : 'w-6 h-6 flex items-center justify-center rounded-full bg-[#F2F4F6] border border-[#E5E8EB] transition'}>
                  <span className={s.done ? 'material-icons text-white text-base' : 'material-icons text-[#D1D6DB] text-base'}>check</span>
                </button>
                {selectedIdx === i && (
                  <button onClick={e => { e.stopPropagation(); handleDeleteSchedule(i); }} className="ml-2 px-3 h-8 rounded-full bg-[#FA2E55] text-white text-xs font-bold shadow active:scale-95 transition animate-fade-in">삭제</button>
                )}
              </div>
            </div>
          ))}
        </div>
        {/* 새 일정 등록 */}
        {showAddForm ? (
          <div className="bg-[#F9FAFB] rounded-xl p-4 border border-[#F2F4F6]">
            <div className="text-sm font-bold text-[#191F28] mb-3">새 일정 등록</div>
            <div className="mb-3">
              <div className="text-xs text-[#8B95A1] mb-1">날짜 선택</div>
              <input type="text" className="w-full h-10 rounded-lg border border-[#E5E8EB] bg-[#F2F4F6] px-3 text-sm text-[#191F28]" value={addDate} onChange={e => setAddDate(e.target.value)} />
            </div>
            <div className="mb-4">
              <div className="text-xs text-[#8B95A1] mb-1">당번 선택</div>
              <div className="flex gap-2 flex-wrap">
                {members.map((m, i) => (
                  <button key={i} className={`px-3 h-8 rounded-full border ${addMember === m ? 'border-[#FA2E55] bg-[#FA2E55] text-white font-bold' : 'border-[#E5E8EB] bg-white text-[#191F28]'}`} onClick={() => setAddMember(m)}>{m}</button>
                ))}
              </div>
            </div>
            <button className="w-full h-11 bg-[#FA2E55] text-white rounded-xl text-[16px] font-bold flex items-center justify-center gap-2 mt-2 active:scale-95 transition" onClick={handleAddSchedule}>등록하기</button>
          </div>
        ) : (
          <button className="w-full h-11 bg-[#FA2E55] text-white rounded-xl text-[16px] font-bold flex items-center justify-center gap-2 mt-2 active:scale-95 transition" onClick={() => setShowAddForm(true)}>새 일정 등록하기</button>
        )}
        {/* 카테고리 삭제 버튼 (기본 3개는 숨김) */}
        {onDeleteChore && !['청소','분리수거','설거지'].includes(choreType) && (
          <button
            className="w-full h-11 mt-8 bg-[#FFF0F4] text-[#FA2E55] rounded-xl text-[16px] font-bold flex items-center justify-center gap-2 active:scale-95 transition border-2 border-[#FA2E55]"
            onClick={() => onDeleteChore(choreType)}
          >
            카테고리 삭제하기
          </button>
        )}
      </div>
    </div>
  );
} 