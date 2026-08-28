package com.moa.service;

import com.moa.filter.exception.FileStorageException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

/**
 * "스터디 등록" 화면의 사진 업로드(ClubService.createClub)를 위한 아주 단순한
 * 로컬 디스크 저장소. S3 같은 오브젝트 스토리지 대신 로컬 디스크를 쓰는 이유는
 * (1) 이 프로젝트가 아직 단일 인스턴스로만 배포되고, (2) 별도 클라우드 스토리지
 * 계정/자격 증명을 새로 도입할 단계가 아니기 때문이다. 여러 대의 서버로
 * 스케일아웃하게 되면 그때 S3(or 유사 서비스)로 옮기는 게 맞다.
 *
 * 저장 경로(app.upload.dir)는 WebMvcConfig가 "/uploads/**"로 정적 서빙하고,
 * WebSecurityConfig가 그 경로를 인증 없이 접근 가능하게 열어둔다 —
 * Image.network(thumbnailUrl)가 Authorization 헤더 없이 바로 불러올 수 있어야
 * 하기 때문이다.
 */
@Service
public class FileStorageService {

    private final Path uploadRoot;

    public FileStorageService(@Value("${app.upload.dir:uploads}") String uploadDir) {
        this.uploadRoot = Paths.get(uploadDir).toAbsolutePath().normalize();
        try {
            Files.createDirectories(this.uploadRoot);
        } catch (IOException e) {
            throw new IllegalStateException("업로드 디렉터리를 만들 수 없습니다: " + this.uploadRoot, e);
        }
    }

    /**
     * 스터디(동아리) 썸네일 사진을 저장하고, 클라이언트가 바로 Image.network로
     * 불러올 수 있는 절대 URL을 돌려준다. 원본 파일명은 신뢰하지 않고
     * UUID + 확장자로 새로 지어서 저장한다(경로 조작/충돌 방지).
     */
    public String storeClubThumbnail(MultipartFile file) {
        Path targetDir = uploadRoot.resolve("clubs");
        try {
            Files.createDirectories(targetDir);
            String filename = UUID.randomUUID() + extensionOf(file.getOriginalFilename());
            Path target = targetDir.resolve(filename);
            file.transferTo(target);
            return ServletUriComponentsBuilder.fromCurrentContextPath()
                    .path("/uploads/clubs/")
                    .path(filename)
                    .toUriString();
        } catch (IOException e) {
            throw new FileStorageException("사진 업로드에 실패했어요.", e);
        }
    }

    private String extensionOf(String originalFilename) {
        if (originalFilename == null) {
            return "";
        }
        int dot = originalFilename.lastIndexOf('.');
        return dot >= 0 ? originalFilename.substring(dot) : "";
    }
}
