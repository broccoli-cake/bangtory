import React, { useState, useEffect } from 'react';

const initialMembers = [
  { id: 1, name: '김민영', isOwner: true },
  { id: 2, name: '민수연', isOwner: false },
  { id: 3, name: '룸메 동동 토마토 수하니', isOwner: false },
];

export default function RoomManageScreen({ onBack }: { onBack?: () => void }) {
  const [roomName, setRoomName] = useState('방토리네');
  const [editMode, setEditMode] = useState(false);
  const [members, setMembers] = useState(initialMembers);
  const [showMemberManage, setShowMemberManage] = useState(false);
  const [actionTarget, setActionTarget] = useState<number | null>(null);
  const [actionType, setActionType] = useState<'kick' | 'delegate' | null>(null);
  const [showActionModal, setShowActionModal] = useState(false);
  const [showInvite, setShowInvite] = useState(false);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const inviteCode = 'QWdfg1234';

  // 주소 예시
  const address = '(12345) 경기 용인시 수지구 죽전로 152\n(00동, 한국마을 0단지아파트) 111동 1111호';

  // 멤버 관리 액션
  const handleAction = (id: number, type: 'kick' | 'delegate') => {
    setActionTarget(id);
    setActionType(type);
    setShowActionModal(true);
  };

  const handleActionConfirm = () => {
    // 실제 내보내기/위임 처리 로직
    setShowActionModal(false);
    setActionTarget(null);
    setActionType(null);
  };

  // 모달 자동 닫기: 멤버 관리 화면이 아닐 때 팝업/모달 닫기
  useEffect(() => {
    if (!showMemberManage) {
      setActionTarget(null);
      setActionType(null);
      setShowActionModal(false);
    }
  }, [showMemberManage]);

  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] h-[844px] w-full bg-white shadow-2xl rounded-[24px] flex flex-col overflow-hidden relative">
        {/* 상단 헤더 */}
        <div className="flex items-center justify-between px-4 pt-6 pb-2 bg-white z-10 border-b border-[#F2F4F6]">
          <button onClick={onBack} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
          <div className="flex-1 text-center text-lg font-bold text-[#191F28]">방 관리</div>
          <div className="w-8" />
        </div>
        {/* 방 이름/주소 */}
        <div className="px-6 pt-6 pb-2">
          <div className="text-xs text-[#8B95A1] mb-1">방 이름</div>
          <div className="flex items-center gap-2 mb-4">
            <input
              className="flex-1 h-12 rounded-xl border border-[#E5E8EB] bg-white px-4 text-base text-[#191F28] focus:outline-none focus:border-[#FA2E55]"
              value={roomName}
              onChange={e => setRoomName(e.target.value)}
              disabled={!editMode}
            />
            <button onClick={() => setEditMode(e => !e)} className="text-[#8B95A1]">
              <span className="material-icons text-xl">{editMode ? 'check' : 'edit'}</span>
            </button>
          </div>
          <div className="text-xs text-[#8B95A1] mb-1">현재 주소</div>
          <div className="rounded-xl border border-[#E5E8EB] bg-[#F9FAFB] px-4 py-3 text-sm text-[#191F28] whitespace-pre-line mb-4">
            {address}
          </div>
        </div>
        {/* 관리 메뉴 */}
        <div className="px-4">
          <div className="bg-[#F9FAFB] rounded-xl overflow-hidden border border-[#F2F4F6] divide-y divide-[#F2F4F6]">
            <button className="w-full flex items-center justify-between px-4 py-4 text-sm text-[#191F28] font-medium" onClick={() => setShowMemberManage(true)}>
              멤버 관리
              <span className="material-icons text-base text-[#8B95A1]">chevron_right</span>
            </button>
            <button className="w-full flex items-center justify-between px-4 py-4 text-sm text-[#191F28] font-medium" onClick={() => setShowInvite(true)}>
              멤버 초대
              <span className="material-icons text-base text-[#8B95A1]">chevron_right</span>
            </button>
            <button className="w-full flex items-center justify-between px-4 py-4 text-sm font-bold text-[#FA2E55]" onClick={() => setShowDeleteModal(true)}>
              방 삭제
            </button>
          </div>
        </div>
        {/* 멤버 관리 화면 */}
        {showMemberManage && (
          <div className="absolute inset-0 bg-white z-20 flex flex-col">
            <div className="flex items-center justify-between px-4 pt-6 pb-2 border-b border-[#F2F4F6]">
              <button onClick={() => setShowMemberManage(false)} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
              <div className="flex-1 text-center text-lg font-bold text-[#191F28]">멤버 관리</div>
              <div className="w-8" />
            </div>
            <div className="flex-1 px-4 py-4 space-y-2">
              {members.map(m => (
                <div key={m.id} className="flex items-center bg-[#F9FAFB] rounded-xl px-4 py-3 border border-[#E5E8EB]">
                  <div className="w-10 h-10 rounded-full bg-[#E5E8EB] mr-3" />
                  <div className="flex-1 flex items-center gap-2">
                    <span className="text-sm text-[#191F28] font-bold">{m.name}</span>
                    {m.isOwner && <span className="material-icons text-base text-[#FA2E55]">workspace_premium</span>}
                  </div>
                  {!m.isOwner && (
                    <div className="relative">
                      <button className="w-8 h-8 flex items-center justify-center text-[#8B95A1]" onClick={() => setActionTarget(m.id)}>
                        <span className="material-icons">more_vert</span>
                      </button>
                      {actionTarget === m.id && (
                        <div className="absolute right-0 top-10 bg-white border border-[#E5E8EB] rounded-xl shadow-lg z-30 min-w-[120px]">
                          <button className="w-full px-4 py-2 text-left text-sm text-[#FA2E55] hover:bg-[#FA2E55]/10 rounded-t-xl" onClick={() => handleAction(m.id, 'kick')}>내보내기</button>
                          <button className="w-full px-4 py-2 text-left text-sm text-[#191F28] hover:bg-[#F2F4F6] rounded-b-xl" onClick={() => handleAction(m.id, 'delegate')}>방장 위임하기</button>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}
        {/* 멤버 초대 모달 */}
        {showInvite && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/20 z-30">
            <div className="bg-white rounded-2xl p-6 w-80 max-w-[90vw] flex flex-col items-center shadow-xl">
              <div className="w-full text-center text-lg font-bold text-[#191F28] mb-4">룸메이트들을 초대하세요!</div>
              <div className="w-full text-xs text-[#8B95A1] mb-1">초대 코드</div>
              <div className="w-full flex items-center justify-center mb-2">
                <div className="text-2xl font-bold text-[#FA2E55] bg-[#F9FAFB] rounded-xl px-4 py-2 border border-[#E5E8EB] select-all">{inviteCode}</div>
              </div>
              <div className="w-full text-xs text-[#8B95A1] mb-4">3분간 유효한 코드입니다.</div>
              <div className="w-full text-xs text-[#8B95A1] mb-6">초대할 룸메이트들에게 비밀 코드를 복사해서 보내보세요.</div>
              <button className="w-full h-12 bg-[#FA2E55] text-white rounded-xl text-[18px] font-bold flex items-center justify-center gap-2 active:scale-95 transition mb-2" onClick={() => {navigator.clipboard.writeText(inviteCode)}}>복사하기</button>
              <button className="w-full h-10 rounded-xl border border-[#E5E8EB] bg-white text-[#191F28] text-sm font-bold" onClick={() => setShowInvite(false)}>닫기</button>
            </div>
          </div>
        )}
        {/* 방 삭제 모달 */}
        {showDeleteModal && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/20 z-30">
            <div className="bg-white rounded-2xl p-6 w-80 max-w-[90vw] flex flex-col items-center shadow-xl">
              <span className="material-icons text-4xl text-[#FA2E55] mb-2">warning_amber</span>
              <div className="text-lg font-bold text-[#FA2E55] mb-1">방 삭제</div>
              <div className="text-sm text-[#191F28] mb-6">이 방을 정말 삭제하시겠습니까?</div>
              <div className="flex gap-3 w-full">
                <button className="flex-1 h-10 rounded-xl border border-[#E5E8EB] bg-white text-[#191F28] text-sm font-bold" onClick={() => setShowDeleteModal(false)}>취소</button>
                <button className="flex-1 h-10 rounded-xl bg-[#FA2E55] text-white text-sm font-bold" onClick={() => { setShowDeleteModal(false); /* 실제 방 삭제 처리 */ }}>삭제</button>
              </div>
            </div>
          </div>
        )}
        {/* 내보내기/위임 모달 */}
        {showActionModal && actionTarget !== null && actionType && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/20 z-30">
            <div className="bg-white rounded-2xl p-6 w-80 max-w-[90vw] flex flex-col items-center shadow-xl">
              <span className="material-icons text-4xl text-[#FA2E55] mb-2">warning_amber</span>
              <div className="text-lg font-bold text-[#FA2E55] mb-1">{actionType === 'kick' ? '내보내기' : '방장 위임하기'}</div>
              <div className="text-sm text-[#191F28] mb-6">
                {actionType === 'kick'
                  ? `'${members.find(m => m.id === actionTarget)?.name}'님을 정말 내보내시겠습니까?`
                  : `'${members.find(m => m.id === actionTarget)?.name}'님에게 방장을 위임하시겠습니까?`}
              </div>
              <div className="flex gap-3 w-full">
                <button className="flex-1 h-10 rounded-xl border border-[#E5E8EB] bg-white text-[#191F28] text-sm font-bold" onClick={() => setShowActionModal(false)}>취소</button>
                <button className="flex-1 h-10 rounded-xl bg-[#FA2E55] text-white text-sm font-bold" onClick={handleActionConfirm}>확인</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
} 