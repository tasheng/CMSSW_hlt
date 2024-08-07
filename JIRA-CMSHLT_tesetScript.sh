#!/bin/bash

jobTag=threads4
hltMenu=/users/musich/tests/dev/CMSSW_14_0_0/CMSHLT-3116/HLT/V6

check_log () {
	
  grep '0 HLT_PPRefDmesonTrackingGlobal_Dpt25_v' $1 | grep TrigReport
}

run(){
  echo $2
  cp $1 $2.py
  cat <<EOF >> $2.py

import os
# file_path = 'DQMIO.root'
file_path = '${2}.root'
if os.path.exists(file_path):
    os.remove(file_path)

#process.hltPuAK4CaloJets.subtractorName = "" 

process.options.numberOfThreads = 6
process.options.numberOfStreams = 0

process.hltOutputMinimal.outputCommands += [
  'keep *_hltFullIter*_*_HLTX',
  #'keep *_hltGtStage2Digis_*_HLTX', 
  #'keep *_hltGtStage2ObjectMap_*_HLTX', 
  #'keep *_hltEcalDigisLegacy_*_HLTX', 
  #'keep *_hltHfprereco_*_HLTX', 
  #'keep *_hltHfreco_*_HLTX', 
  #'keep *_hltHoreco_*_HLTX', 
  'keep *_hltTowerMakerForAll_*_HLTX', 
  'keep *_hltAK4CaloJets_*_*', 
  'keep *_hltAK4CaloJetsIDPassed_*_*', 
  'keep *_hltFixedGridRhoFastjetAllCalo_*_*', 
  #'keep *_hltAK4CaloFastJetCorrector_*_*', 
  #'keep *_hltAK4CaloRelativeCorrector_*_*', 
  #'keep *_hltAK4CaloAbsoluteCorrector_*_*', 
  #'keep *_hltPuAK4CaloCorrector_*_*', 
  #'keep *_hltPuAK4CaloJetsCorrected_*_*', 
  #'keep *_hltPuAK4CaloJetsCorrectedIDPassed_*_*', 
]
process.source = cms.Source( "PoolSource",
    fileNames = cms.untracked.vstring(

'file:/afs/cern.ch/work/s/soohwan/public/ForTzuAn/step2_PU10.root',
    ),
    inputCommands = cms.untracked.vstring(
        'keep *'
    ),
    #eventsToProcess = cms.untracked.VEventRange(
    #   '1:1:5-1:1:5'
    #),
    # eventsToProcess = cms.untracked.VEventRange(
    #    '1:1:5-1:1:5','1:1:93-1:1:109' 
    # ),
)
#process.hltPuAK4CaloJets.doAreaFastjet = cms.bool( False )
process.hltAK4CaloJets.verbosity = cms.int32( 99999 )


process.hltOutputMinimal.fileName = '${2}.root'
EOF
  cmsRun "${2}".py &> "${2}".log
  check_log "${2}".log
}

hltGetCmd="hltGetConfiguration ${hltMenu}"
hltGetCmd+=" --globaltag auto:run3_mc_PRef --mc --unprescale --output minimal --max-events -1"
# hltGetCmd+=" --input file:/eos/cms/store/group/phys_heavyions/tsheng/run24/Pythia8_DzeroToKPi_prompt_Pthat40_TuneCP5_5360GeV/MC_20240530_pthat40_DIGI_v1/240530_152336/0000/signal_RAW_full_3.root"
hltGetCmd+=" --input file:/afs/cern.ch/work/s/soohwan/public/ForTzuAn/step2_PU10.root"

#echo $hltGetCmd

configLabel=hlt_"${jobTag}"_onlyHICsAK4PFJet
#echo "${configLabel}".py
${hltGetCmd} --paths HLT_PPRefDmesonTrackingGlobal_Dpt25_v2 > "${configLabel}".py
for job_i in {0..50}; do run "${configLabel}".py "${configLabel}"_"${job_i}"; done; unset job_i;
wait

configLabel=hlt_"${jobTag}"_full
${hltGetCmd} > "${configLabel}".py
