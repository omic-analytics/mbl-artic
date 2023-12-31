process makeQCCSV {
    tag { sampleName }

    publishDir "${params.outdir}/qc_plots", pattern: "${sampleName}.depth.png", mode: 'copy'

    input:
    tuple sampleName, path(bam), path(fasta), path(ref)

    output:
    path "${params.prefix}.${sampleName}.qc.csv", emit: csv
    path "${sampleName}.depth.png"

    script:
    if ( params.illumina ) {
       qcSetting = "--illumina"
    } else {
       qcSetting = "--nanopore"
    }

    """
    qc.py ${qcSetting} --outfile ${params.prefix}.${sampleName}.qc.csv --sample ${sampleName} --ref ${ref} --bam ${bam} --fasta ${fasta}
    """
}


process writeQCSummaryCSV {
    tag { params.prefix }

    publishDir "${params.outdir}", pattern: "${params.prefix}.qc.csv", mode: 'copy'

    input:
    val lines

    output:
    path "${params.prefix}.qc.csv", emit: qcsummary

    exec:
    file("${task.workDir}/${params.prefix}.qc.csv").withWriter { writer ->
        for ( line in lines ) {
            writer.writeLine(line.join(','))
         }   
    }
}

