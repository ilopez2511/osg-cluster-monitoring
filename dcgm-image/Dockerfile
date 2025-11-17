FROM nvidia/dcgm:4.4.1-2-ubuntu22.04
COPY dcgm_csv_collector.sh /root/
RUN chmod +x /root/dcgm_csv_collector.sh
ENTRYPOINT ["/root/dcgm_csv_collector.sh"]
