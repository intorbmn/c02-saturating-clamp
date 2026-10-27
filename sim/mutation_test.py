import subprocess,re,os,sys,tempfile
# Chay tu thu muc goc repo: python3 sim/mutation_test.py
os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..'))
os.makedirs('waveforms',exist_ok=True)
TMP=tempfile.mkdtemp()
src=open('rtl/sat_clamp.v').read()
M={
'M1 s<=lo':('assign below = (s < lo);','assign below = (s <= lo);'),
'M2 s>=hi':('assign above = (s > hi);','assign above = (s >= hi);'),
'M3 lo-1':('assign below = (s < lo);','assign below = (s < lo - 8\'d1);'),
'M4 hi+1':('assign above = (s > hi);','assign above = (s > hi + 8\'d1);'),
'M5 swap prio':('below ? lo : (above ? hi : s)','above ? hi : (below ? lo : s)'),
'M6 flag=below':('{7\'b0, below | above}','{7\'b0, below}'),
'M7 flag=0':('{7\'b0, below | above}','8\'b0'),
'M8 hi low bits':("{uio_in[3:1], 5'h1F}","{uio_in[3:1], 5'h0F}"),
'M9 swap lo/hi mux':('below ? lo : (above ? hi : s)','below ? hi : (above ? lo : s)'),
'M10 signed cmp':('assign below = (s < lo);\n    assign above = (s > hi);','assign below = ($signed(s) < $signed(lo));\n    assign above = ($signed(s) > $signed(hi));'),
}
def ref(s,cfg):
    lo=(cfg>>4)<<4; hi=(((cfg>>1)&7)<<5)|31
    if s<lo: return lo,1
    if s>hi: return hi,1
    return s,0
cases=[('TC-01',0x30,0x4A),('TC-02',0x40,0x4A),('TC-03',0x80,0x4A),('TC-04',0xBF,0x4A),('TC-05',0xF0,0x4A),('TC-06a',0x3F,0x4A),('TC-06b',0xC0,0x4A),('TC-07a',0x00,0x0E),('TC-07b',0xFF,0x0E)]
def run(code):
    open(TMP+'/m.v','w').write(code)
    r={}
    subprocess.run(['iverilog','-o',TMP+'/a',TMP+'/m.v','tb/tb_sat_clamp.v'],check=True)
    o=subprocess.run(['vvp',TMP+'/a'],capture_output=True,text=True,cwd='.').stdout
    outs=re.findall(r'out=0x([0-9a-f]{2})\s+clamp=(\d)',o)
    red=[]
    for (n,s,c),(y,f) in zip(cases,outs):
        if (int(y,16),int(f))!=ref(s,c): red.append(n)
    subprocess.run(['iverilog','-o',TMP+'/b',TMP+'/m.v','tb/tb_sat_clamp_selfcheck.v'],check=True)
    o2=subprocess.run(['vvp',TMP+'/b'],capture_output=True,text=True).stdout
    sw=re.search(r'so phep kiem: (\d+), loi: (\d+)',o2)
    return red,sw.groups() if sw else None,'ALL TESTS PASSED' in o2
print('baseline',run(src))
for k,(a,b) in M.items():
    assert a in src,k
    print(k,run(src.replace(a,b)))
