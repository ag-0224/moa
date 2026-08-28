package com.moa.filter.exception;

/**
 * 업로드된 파일(스터디 사진 등)을 디스크에 저장하는 중 IO 오류가 발생했을 때
 * FileStorageService가 던진다.
 */
public class FileStorageException extends RuntimeException {
    public FileStorageException(String message, Throwable cause) {
        super(message, cause);
    }
}
